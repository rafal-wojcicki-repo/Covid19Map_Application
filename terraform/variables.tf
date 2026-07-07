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
  default     = []
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

variable "artifact_bucket_force_destroy" {
  description = "Allow destroying non-empty deployment artifact bucket."
  type        = bool
  default     = false
}

variable "github_oidc_subjects" {
  description = "Allowed OIDC token subjects for GitHub Actions role assumption."
  type        = list(string)
  default = [
    "repo:Bizon15100/Covid19Map_Application:ref:refs/heads/main",
    "repo:Bizon15100/Covid19Map_Application:ref:refs/heads/master",
    "repo:Bizon15100/Covid19Map_Application:environment:production"
  ]
}

variable "github_oidc_provider_arn" {
  description = "Optional existing GitHub OIDC provider ARN. If null, Terraform creates one."
  type        = string
  default     = null
}

variable "tags" {
  description = "Additional tags applied to all resources."
  type        = map(string)
  default     = {}
}
