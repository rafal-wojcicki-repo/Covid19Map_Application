# Covid19Map_Application

Spring Boot + Thymeleaf application showing COVID-19 deaths on a map using data from:
https://github.com/CSSEGISandData/COVID-19/blob/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv

## Run locally

1. Build and run:
   - `mvn clean spring-boot:run`
2. Open:
   - `http://localhost:8080/map` (map view)
   - `http://localhost:8080` (JSON points)
   - `http://localhost:8080/health` (health)

## AWS deployment (Terraform + GitHub Actions + CodeDeploy)

Infrastructure is defined in `terraform/`.
CI/CD workflow is in `.github/workflows/covid-19-deaths-app-ci-cd.yml`.

Use Terraform outputs to fill GitHub Actions settings:

- **Secret**
  - `AWS_ROLE_TO_ASSUME`
- **Variables**
  - `AWS_REGION`
  - `CODEDEPLOY_APPLICATION_NAME`
  - `CODEDEPLOY_DEPLOYMENT_GROUP`
  - `CODEDEPLOY_ARTIFACT_BUCKET`
  - `CODEDEPLOY_ARTIFACT_PREFIX`

## Security / sensitive files

Do **not** commit real environment or state files:

- `terraform/terraform.tfvars`
- `terraform/*.tfstate*`
- `terraform/.terraform/`
- `*.pem`, `*.key`, `.env*`

Commit only templates like `terraform/terraform.tfvars.example`.