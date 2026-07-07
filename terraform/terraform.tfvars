aws_region         = "eu-central-1"
project_name       = "covid19map"
environment        = "dev"
instance_type      = "t3.micro"
vpc_cidr           = "10.40.0.0/16"
public_subnet_cidr = "10.40.1.0/24"
ssh_port           = 22

# Ogranicz do swojego IP/Bastion/VPN.
ssh_ingress_cidrs       = ["0.0.0.0/0"]
allow_insecure_ssh_cidr = false

# Port aplikacji.
app_port          = 8080
app_ingress_cidrs = ["0.0.0.0/0"]

app_dir              = "/opt/covid19map"
systemd_service_name = "covid19map.service"
create_eip           = true
artifact_bucket_force_destroy = false
github_oidc_provider_arn = "arn:aws:iam::990393187402:oidc-provider/token.actions.githubusercontent.com"

tags = {
  Owner = "rafal-wojcicki"
}
