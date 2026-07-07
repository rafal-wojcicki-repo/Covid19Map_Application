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

variable "vpc_cidr" {
  description = "CIDR block for dedicated VPC."
  type        = string
  default     = "10.40.0.0/16"
}

variable "public_subnet_cidr_a" {
  description = "CIDR block for public subnet A."
  type        = string
  default     = "10.40.1.0/24"
}

variable "public_subnet_cidr_b" {
  description = "CIDR block for public subnet B."
  type        = string
  default     = "10.40.2.0/24"
}

variable "app_port" {
  description = "Application port exposed by ECS container and target group."
  type        = number
  default     = 8080
}

variable "task_cpu" {
  description = "ECS task CPU units."
  type        = number
  default     = 256
}

variable "task_memory" {
  description = "ECS task memory in MiB."
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Desired number of ECS tasks."
  type        = number
  default     = 1
}

variable "container_image_tag" {
  description = "Default container image tag used by Terraform-created task definition."
  type        = string
  default     = "latest"
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
