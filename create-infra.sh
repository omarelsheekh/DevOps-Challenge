# Create Infra
echo "Creating infra on azure"
terraform init
terraform plan
terraform apply #-auto-approve
