locals {
  name = "${var.project_name}-${var.environment}"
  ssh_public_key_from_path = (
    var.ssh_public_key_path != null && trimspace(var.ssh_public_key_path) != ""
    ? trimspace(file(var.ssh_public_key_path))
    : null
  )
  ssh_public_key = trimspace(coalesce(var.ssh_public_key, local.ssh_public_key_from_path, ""))

  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    },
    var.tags
  )
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(local.common_tags, { Name = "${local.name}-vpc" })
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = merge(local.common_tags, { Name = "${local.name}-igw" })
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = merge(local.common_tags, { Name = "${local.name}-public-subnet" })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags   = merge(local.common_tags, { Name = "${local.name}-public-rt" })
}

resource "aws_route" "default_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "app" {
  name        = "${local.name}-app-sg"
  description = "Security group for Covid19Map EC2 instance"
  vpc_id      = aws_vpc.main.id

  dynamic "ingress" {
    for_each = var.ssh_ingress_cidrs
    content {
      from_port   = var.ssh_port
      to_port     = var.ssh_port
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
      description = "SSH access"
    }
  }

  dynamic "ingress" {
    for_each = var.app_ingress_cidrs
    content {
      from_port   = var.app_port
      to_port     = var.app_port
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
      description = "Application access"
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  lifecycle {
    precondition {
      condition     = length(var.ssh_ingress_cidrs) > 0
      error_message = "Set at least one CIDR in ssh_ingress_cidrs to allow deployment access."
    }

    precondition {
      condition     = var.allow_insecure_ssh_cidr || !contains(var.ssh_ingress_cidrs, "0.0.0.0/0")
      error_message = "0.0.0.0/0 for SSH is blocked by default. Set allow_insecure_ssh_cidr=true only for temporary use."
    }
  }

  tags = merge(local.common_tags, { Name = "${local.name}-app-sg" })
}

resource "aws_key_pair" "deployer" {
  key_name   = "${local.name}-key"
  public_key = local.ssh_public_key

  lifecycle {
    precondition {
      condition     = local.ssh_public_key != ""
      error_message = "Set ssh_public_key (OpenSSH one-line public key) or ssh_public_key_path (.pub file path)."
    }

    precondition {
      condition = can(regex(
        "^(ssh-(rsa|ed25519)|ecdsa-sha2-nistp(256|384|521))\\s+[A-Za-z0-9+/=]+(?:\\s+.*)?$",
        local.ssh_public_key
      ))
      error_message = "Invalid SSH public key format. Use OpenSSH public key, e.g. 'ssh-ed25519 AAAA... comment'."
    }
  }

  tags = merge(local.common_tags, { Name = "${local.name}-key" })
}

resource "aws_iam_role" "ec2_ssm" {
  name = "${local.name}-ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = merge(local.common_tags, { Name = "${local.name}-ec2-ssm-role" })
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ec2_ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2" {
  name = "${local.name}-ec2-profile"
  role = aws_iam_role.ec2_ssm.name
  tags = merge(local.common_tags, { Name = "${local.name}-ec2-profile" })
}

resource "aws_instance" "app" {
  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  key_name                    = aws_key_pair.deployer.key_name
  vpc_security_group_ids      = [aws_security_group.app.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2.name
  associate_public_ip_address = true
  monitoring                  = true

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    encrypted   = true
    volume_type = "gp3"
    volume_size = 16
  }

  user_data = <<-EOT
              #!/bin/bash
              set -e
              dnf update -y
              dnf install -y java-11-amazon-corretto-headless

              APP_DIR="${var.app_dir}"
              SERVICE_NAME="${var.systemd_service_name}"

              mkdir -p "$APP_DIR/releases"
              chown -R ec2-user:ec2-user "$APP_DIR"
              touch "$APP_DIR/current.jar"
              chown ec2-user:ec2-user "$APP_DIR/current.jar"

              cat <<'SERVICE_EOF' > "/etc/systemd/system/${var.systemd_service_name}"
              [Unit]
              Description=Covid19Map Spring Boot Application
              After=network.target

              [Service]
              Type=simple
              User=ec2-user
              WorkingDirectory=${var.app_dir}
              ExecStart=/usr/bin/java -jar ${var.app_dir}/current.jar
              Restart=always
              RestartSec=5
              SuccessExitStatus=143

              [Install]
              WantedBy=multi-user.target
              SERVICE_EOF

              systemctl daemon-reload
              systemctl enable "$SERVICE_NAME"
              EOT

  tags = merge(local.common_tags, { Name = "${local.name}-ec2" })
}

resource "aws_eip" "app" {
  count    = var.create_eip ? 1 : 0
  domain   = "vpc"
  instance = aws_instance.app.id
  tags     = merge(local.common_tags, { Name = "${local.name}-eip" })
}
