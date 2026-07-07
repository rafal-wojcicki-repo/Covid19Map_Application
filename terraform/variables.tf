variable "aws_region" {
  description = "AWS region for all resources."
  type        = string
  default     = "eu-central-1"
}

variable "project_name" {
  description = "Project name used in resource naming."
  type        = string
  default     = "covid19map"
}

variable "environment" {
  description = "Environment label (e.g. dev, prod)."
  type        = string
  default     = "dev"
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "vpc_cidr" {
  description = "CIDR block for dedicated VPC."
  type        = string
  default     = "10.40.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet."
  type        = string
  default     = "10.40.1.0/24"
}

variable "ssh_port" {
  description = "SSH port exposed by EC2."
  type        = number
  default     = 22
}

variable "ssh_ingress_cidrs" {
  description = "CIDRs allowed to SSH into EC2. Restrict to trusted sources."
  type        = list(string)
  default     = ["79.184.211.96/32"]
}

variable "allow_insecure_ssh_cidr" {
  description = "Allow 0.0.0.0/0 for SSH ingress. Keep false in production."
  type        = bool
  default     = false
}

variable "app_port" {
  description = "Application port exposed publicly."
  type        = number
  default     = 8080
}

variable "app_ingress_cidrs" {
  description = "CIDRs allowed to access application port."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "ssh_public_key" {
  description = "Public SSH key content in OpenSSH format (ssh-rsa/ssh-ed25519/ecdsa-...)."
  type        = string
  default     = null
  nullable    = true
}

variable "ssh_public_key_path" {
  description = "Optional path to OpenSSH public key file (e.g. ~/.ssh/id_ed25519.pub). Used when ssh_public_key is null."
  type        = string
  default     = null
  nullable    = true
}

variable "app_dir" {
  description = "Application directory used by deployment workflow and systemd."
  type        = string
  default     = "/opt/covid19map"
}

variable "systemd_service_name" {
  description = "Systemd unit name used by GitHub Actions restart step."
  type        = string
  default     = "covid19map.service"
}

variable "create_eip" {
  description = "Attach Elastic IP to have stable host for GitHub secret EC2_HOST."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags applied to all resources."
  type        = map(string)
  default     = {}
}
