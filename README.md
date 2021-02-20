# DevOps-Challenge
This is a solution for a [DevOps Challenge](/DevOps-Challenge.pdf)
#### there are 2 options to deploy the app
- #### [Option 1](#option1)
- #### [Option 2](#option2)
## <a name="option1">Option #1</a>
in this option i have created 3 VMs: 
- App VM
- MasterDB VM
- SlaveDB VM
#### and deployed them all on Microsoft Azure using Terraform then configured them using Ansible

### Getting Started

1. [Install Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
2. [Install azure Cli](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
3. log in to your azure account 
```bash
az login
```
4. Make Sure that your subscription is active 
```bash
az account list
```
```bash
you should get a response like this

[
  {
    "cloudName": "AzureCloud",
    "homeTenantId": "f6****22-84be-48a6-b**c-c0*******1f1",
    "id": "b7*****1-475c-41a6-a**2-d********f1c",
    "isDefault": true,
    "managedByTenants": [],
    "name": "Azure for Students",
    "state": "Enabled",
    "tenantId": "f6****22-84be-48a6-b**c-c0*******1f1",
    "user": {
      "name": "foo@ex.com",
      "type": "user"
    }
  }
]
```
5. [Install Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
6. Clone this repo
```bash
git clone https://github.com/omarelsheekh/DevOps-Challenge
```
7. Change your directory to the repo
```bash
cd DevOps-Challenge
```
8. Change default variables in [variables.tf](/variables.tf) if you want
### Start Building All Infra in One Command
```bash
./create-infra.sh
```
### Destroy Infra Whenever you want
```bash
./destroy-infra.sh
```
## <a name="option2">Option #2</a>
