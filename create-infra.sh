# # Create Infra
# echo "Creating infra on azure"
# terraform init
# terraform plan
# terraform apply #-auto-approve

# # Grapping VMs IPs
# echo "Grapping VMs IPs"
# rm -f ansible/inventory
# echo "[APPVM]" >> ansible/inventory
# az vm show --resource-group $(terraform output -raw rg_name) \
#     --name $(terraform output -raw app_vm_name) \
#     -d --query [publicIps] -o tsv >> ansible/inventory
# echo "[DBMasterVM]" >> ansible/inventory
# az vm show --resource-group $(terraform output -raw rg_name) \
#     --name $(terraform output -raw dbmaster_vm_name) \
#     -d --query [publicIps] -o tsv >> ansible/inventory
# echo "[DBSlaveVM]" >> ansible/inventory
# az vm show --resource-group $(terraform output -raw rg_name) \
#     --name $(terraform output -raw dbslave_vm_name) \
#     -d --query [publicIps] -o tsv >> ansible/inventory

# Run Ansible tasks
echo "Run Ansible tasks"
chmod 400 ansible/private_key.pem
ansible-playbook -i ansible/inventory --private-key ansible/private_key.pem ansible/dbmaster_vm.yml -e " \
dbslave_vm_private_ip=$(terraform output -raw dbslave_vm_private_ip) \
db_name=$(terraform output -raw db_name) \
db_username=$(terraform output -raw db_username) \
db_userpass=$(terraform output -raw db_userpass) \
db_replicapass=$(terraform output -raw db_replicapass) \
subnet_prefix=$(terraform output -raw subnet_prefix) \
"
ansible-playbook -i ansible/inventory --private-key ansible/private_key.pem ansible/dbslave_vm.yml -e " \
dbmaster_vm_private_ip=$(terraform output -raw dbmaster_vm_private_ip) \
db_replicapass=$(terraform output -raw db_replicapass) \
"
ansible-playbook -i ansible/inventory --private-key ansible/private_key.pem ansible/app_vm.yml -e " \
db_ip=$(terraform output -raw dbmaster_vm_private_ip) \
db_name=$(terraform output -raw db_name) \
db_username=$(terraform output -raw db_username) \
db_userpass=$(terraform output -raw db_userpass) \
"
echo "***** Finshed Deployment ******"
# replication refrence:
# https://www.youtube.com/watch?v=nnnAmq34STc
# https://gist.github.com/encoreshao/cf919b300497ca863d54383455578906