aws_region         = "eu-central-1"
project_name       = "covid19map"
environment        = "dev"
instance_type      = "t3.micro"
vpc_cidr           = "10.40.0.0/16"
public_subnet_cidr = "10.40.1.0/24"
ssh_port           = 22

# Ogranicz do swojego IP/Bastion/VPN.
ssh_ingress_cidrs       = ["79.184.211.96/32"]
allow_insecure_ssh_cidr = false

# Port aplikacji.
app_port          = 8080
app_ingress_cidrs = ["0.0.0.0/0"]

# Wklej zawartość klucza PUBLICZNEGO (nie prywatnego), np. z pliku id_rsa.pub.
ssh_public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIXObhdurYaIQMDVr3eUNMedwYVEwJXiCtVjIZm14DLg github-actions-deploy"

app_dir              = "/opt/covid19map"
systemd_service_name = "covid19map.service"
create_eip           = true

tags = {
  Owner = "rafal-wojcicki"
}
