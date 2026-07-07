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

output "github_actions_configuration" {
  description = "Values to copy into GitHub Actions secrets/variables."
  value = {
    secrets = {
      EC2_HOST     = var.create_eip ? aws_eip.app[0].public_ip : aws_instance.app.public_ip
      EC2_SSH_USER = "ec2-user"
    }
    vars = {
      EC2_APP_DIR          = var.app_dir
      EC2_SYSTEMD_SERVICE  = var.systemd_service_name
      EC2_SSH_PORT         = tostring(var.ssh_port)
      APP_HEALTHCHECK_PORT = "8080"
      APP_HEALTHCHECK_PATH = "/map"
    }
  }
}
