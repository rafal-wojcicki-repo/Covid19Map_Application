locals {
  name                             = "${var.project_name}-${var.environment}"
  codedeploy_app_name              = "${local.name}-codedeploy-app"
  codedeploy_deployment_group_name = "${local.name}-deployment-group"
  github_oidc_provider_arn         = var.github_oidc_provider_arn != null ? var.github_oidc_provider_arn : aws_iam_openid_connect_provider.github[0].arn

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

data "aws_caller_identity" "current" {}

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
      condition     = var.allow_insecure_ssh_cidr || !contains(var.ssh_ingress_cidrs, "0.0.0.0/0")
      error_message = "0.0.0.0/0 for SSH is blocked by default. Set allow_insecure_ssh_cidr=true only for temporary use."
    }
  }

  tags = merge(local.common_tags, { Name = "${local.name}-app-sg" })
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

resource "aws_iam_role_policy_attachment" "codedeploy_ec2" {
  role       = aws_iam_role.ec2_ssm.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforAWSCodeDeploy"
}

resource "aws_s3_bucket" "deploy_artifacts" {
  bucket        = "${local.name}-deploy-artifacts-${data.aws_caller_identity.current.account_id}"
  force_destroy = var.artifact_bucket_force_destroy
  tags          = merge(local.common_tags, { Name = "${local.name}-deploy-artifacts" })
}

resource "aws_s3_bucket_versioning" "deploy_artifacts" {
  bucket = aws_s3_bucket.deploy_artifacts.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "deploy_artifacts" {
  bucket                  = aws_s3_bucket.deploy_artifacts.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_iam_role_policy" "ec2_artifact_read" {
  name = "${local.name}-ec2-artifact-read"
  role = aws_iam_role.ec2_ssm.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:ListBucket"
      ]
      Resource = [
        aws_s3_bucket.deploy_artifacts.arn,
        "${aws_s3_bucket.deploy_artifacts.arn}/*"
      ]
    }]
  })
}

resource "aws_iam_openid_connect_provider" "github" {
  count           = var.github_oidc_provider_arn == null ? 1 : 0
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

resource "aws_iam_role" "github_actions_deploy" {
  name = "${local.name}-github-actions-deploy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = local.github_oidc_provider_arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
        StringLike = {
          "token.actions.githubusercontent.com:sub" = var.github_oidc_subjects
        }
      }
    }]
  })

  tags = merge(local.common_tags, { Name = "${local.name}-github-actions-deploy-role" })
}

resource "aws_iam_role_policy" "github_actions_deploy" {
  name = "${local.name}-github-actions-deploy-policy"
  role = aws_iam_role.github_actions_deploy.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.deploy_artifacts.arn,
          "${aws_s3_bucket.deploy_artifacts.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "codedeploy:CreateDeployment",
          "codedeploy:GetDeployment",
          "codedeploy:GetDeploymentConfig",
          "codedeploy:RegisterApplicationRevision"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "codedeploy_service" {
  name = "${local.name}-codedeploy-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "codedeploy.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = merge(local.common_tags, { Name = "${local.name}-codedeploy-service-role" })
}

resource "aws_iam_role_policy_attachment" "codedeploy_service" {
  role       = aws_iam_role.codedeploy_service.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}

resource "aws_codedeploy_app" "this" {
  compute_platform = "Server"
  name             = local.codedeploy_app_name
}

resource "aws_codedeploy_deployment_group" "this" {
  app_name               = aws_codedeploy_app.this.name
  deployment_group_name  = local.codedeploy_deployment_group_name
  service_role_arn       = aws_iam_role.codedeploy_service.arn
  deployment_config_name = "CodeDeployDefault.OneAtATime"

  ec2_tag_filter {
    key   = "CodeDeployGroup"
    type  = "KEY_AND_VALUE"
    value = local.name
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }
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
              dnf install -y java-11-amazon-corretto-headless ruby wget

              APP_DIR="${var.app_dir}"
              SERVICE_NAME="${var.systemd_service_name}"

              mkdir -p "$APP_DIR/releases"
              mkdir -p "$APP_DIR/deployment"
              chown -R ec2-user:ec2-user "$APP_DIR"
              touch "$APP_DIR/current.jar"
              chown ec2-user:ec2-user "$APP_DIR/current.jar"

              mkdir -p /etc/covid19map
              cat <<'CONFIG_EOF' > /etc/covid19map/deploy.env
              APP_DIR=${var.app_dir}
              SERVICE_NAME=${var.systemd_service_name}
              HEALTHCHECK_URL=http://localhost:${var.app_port}/health
              CONFIG_EOF
              chmod 644 /etc/covid19map/deploy.env

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

              cd /tmp
              wget "https://aws-codedeploy-${var.aws_region}.s3.${var.aws_region}.amazonaws.com/latest/install"
              chmod +x ./install
              ./install auto
              systemctl enable codedeploy-agent
              systemctl start codedeploy-agent
              EOT

  tags = merge(
    local.common_tags,
    {
      Name            = "${local.name}-ec2"
      CodeDeployGroup = local.name
    }
  )

  depends_on = [
    aws_iam_role_policy_attachment.ssm_core,
    aws_iam_role_policy_attachment.codedeploy_ec2,
    aws_iam_role_policy.ec2_artifact_read
  ]
}

resource "aws_eip" "app" {
  count    = var.create_eip ? 1 : 0
  domain   = "vpc"
  instance = aws_instance.app.id
  tags     = merge(local.common_tags, { Name = "${local.name}-eip" })
}
