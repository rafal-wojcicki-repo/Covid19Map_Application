output "ec2_instance_id" {
  description = "EC2 instance ID."
  value       = aws_instance.app.id
}

output "ec2_public_ip" {
  description = "EC2 public IP (Elastic IP if enabled)."
  value       = var.create_eip ? aws_eip.app[0].public_ip : aws_instance.app.public_ip
}

output "ec2_public_dns" {
  description = "EC2 public DNS name."
  value       = aws_instance.app.public_dns
}

output "ec2_ssh_user" {
  description = "SSH user for Amazon Linux 2023."
  value       = "ec2-user"
}

output "ec2_ssh_port" {
  description = "SSH port for GitHub Actions variable EC2_SSH_PORT."
  value       = var.ssh_port
}

output "ec2_app_dir" {
  description = "Directory for GitHub Actions variable EC2_APP_DIR."
  value       = var.app_dir
}

output "ec2_systemd_service" {
  description = "Systemd service for GitHub Actions variable EC2_SYSTEMD_SERVICE."
  value       = var.systemd_service_name
}

output "codedeploy_application_name" {
  description = "CodeDeploy application name for GitHub Actions variable CODEDEPLOY_APPLICATION_NAME."
  value       = aws_codedeploy_app.this.name
}

output "codedeploy_deployment_group_name" {
  description = "CodeDeploy deployment group name for GitHub Actions variable CODEDEPLOY_DEPLOYMENT_GROUP."
  value       = aws_codedeploy_deployment_group.this.deployment_group_name
}

output "codedeploy_artifact_bucket_name" {
  description = "S3 bucket name for GitHub Actions variable CODEDEPLOY_ARTIFACT_BUCKET."
  value       = aws_s3_bucket.deploy_artifacts.bucket
}

output "github_actions_role_to_assume" {
  description = "IAM role ARN to put in GitHub Actions secret AWS_ROLE_TO_ASSUME."
  value       = aws_iam_role.github_actions_deploy.arn
}

output "github_actions_configuration" {
  description = "Values to copy into GitHub Actions secrets/variables."
  value = {
    secrets = {
      AWS_ROLE_TO_ASSUME = aws_iam_role.github_actions_deploy.arn
    }
    vars = {
      AWS_REGION                  = var.aws_region
      CODEDEPLOY_APPLICATION_NAME = aws_codedeploy_app.this.name
      CODEDEPLOY_DEPLOYMENT_GROUP = aws_codedeploy_deployment_group.this.deployment_group_name
      CODEDEPLOY_ARTIFACT_BUCKET  = aws_s3_bucket.deploy_artifacts.bucket
      CODEDEPLOY_ARTIFACT_PREFIX  = "${var.project_name}/${var.environment}"
    }
  }
}
