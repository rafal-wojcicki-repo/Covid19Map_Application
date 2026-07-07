output "alb_dns_name" {
  description = "Public URL host for the application."
  value       = aws_lb.app.dns_name
}

output "application_url" {
  description = "Public URL of the deployed application."
  value       = "http://${aws_lb.app.dns_name}"
}

output "ecr_repository_url" {
  description = "ECR repository URL used by CI/CD."
  value       = aws_ecr_repository.app.repository_url
}

output "ecs_cluster_name" {
  description = "ECS cluster name."
  value       = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  description = "ECS service name."
  value       = aws_ecs_service.app.name
}

output "ecs_task_family" {
  description = "ECS task definition family used by deployment job."
  value       = aws_ecs_task_definition.app.family
}

output "ecs_container_name" {
  description = "Container name in ECS task definition."
  value       = local.ecs_container_name
}

output "cloudwatch_log_group_name" {
  description = "CloudWatch log group with application logs."
  value       = aws_cloudwatch_log_group.ecs.name
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
      AWS_REGION         = var.aws_region
      ECR_REPOSITORY_URL = aws_ecr_repository.app.repository_url
      ECS_CLUSTER_NAME   = aws_ecs_cluster.main.name
      ECS_SERVICE_NAME   = aws_ecs_service.app.name
      ECS_TASK_FAMILY    = aws_ecs_task_definition.app.family
      ECS_CONTAINER_NAME = local.ecs_container_name
    }
  }
}
