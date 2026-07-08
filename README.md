# Covid19Map_Application

Spring Boot + Thymeleaf application showing COVID-19 deaths on a map using data from:
https://github.com/CSSEGISandData/COVID-19/blob/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv

## Run locally

1. Run from Maven:
   - `mvn clean spring-boot:run`
2. Open:
   - `http://localhost:8080/map` (map view)
   - `http://localhost:8080` (JSON points)
   - `http://localhost:8080/health` (health)

## Run locally in Docker

1. Build image:
   - `docker build -t covid19map:local .`
2. Run container:
   - `docker run --rm -p 8080:8080 covid19map:local`
3. Open:
   - `http://localhost:8080/map`
   - `http://localhost:8080/health`

## AWS deployment (Terraform + GitHub Actions + ECR + ECS)

Infrastructure is in `terraform/` and CI/CD workflow in `.github/workflows/covid-19-deaths-app-ci-cd.yml`.

Terraform creates:
- ECR repository (Docker images),
- ECS Fargate cluster/service,
- Application Load Balancer with public URL,
- CloudWatch log group for container logs,
- IAM role for GitHub OIDC deployment.

After `terraform apply`, copy values from output `github_actions_configuration` to GitHub:

Use Terraform outputs to fill GitHub Actions settings:

- **Secret**
  - `AWS_ROLE_TO_ASSUME`
- **Variables**
  - `AWS_REGION`
  - `ECR_REPOSITORY_URL`
  - `ECS_CLUSTER_NAME`
  - `ECS_SERVICE_NAME`
  - `ECS_TASK_FAMILY`
  - `ECS_CONTAINER_NAME`

Deploy flow on `main/master`:
1. run tests,
2. build Docker image,
3. push image to ECR,
4. update ECS task definition and deploy service.

Public URL is available from Terraform output:
- `application_url`

Container logs in AWS:
- CloudWatch log group from output `cloudwatch_log_group_name`.


Public URL to app: [URL link](http://covid19map-dev-alb-167202307.eu-central-1.elb.amazonaws.com/map)
