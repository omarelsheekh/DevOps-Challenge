# DevOps-Challenge
This is a solution for a [DevOps Challenge](/DevOps-Challenge.pdf)
#### there are 2 options to deploy the app
- #### [Option 1](#option1)
- #### [Option 2](#option2)
## <a name="option1">Option #1</a>
in this option we will deploy 3 VMs: 
- App VM
- MasterDB VM
- SlaveDB VM
#### on Microsoft Azure using Terraform then configured them using Ansible

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
in this option we will deploy a k8s cluster using Rancher on 3 ubuntu 20.04 machines: 
- RancherMaster
- RancherSlave1
- RancherSlave2
### Getting Started

1. [Install Docker](https://docs.docker.com/engine/install/) on all machines
2. [Install kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) on machines you will run commands from
3. [create a new cluster using rancher](/rancher-cluster.pdf)
4. Install helm on machines have kubectl installed
```bash
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
```
5. Clone this repo
```bash
git clone https://github.com/omarelsheekh/DevOps-Challenge
```
6. move to halan-chart directory
```bash
cd DevOps-Challenge/halan-chart
```
7. Run the app helm chart
```bash
helm install app .
```
8. Verify the IP addresses is set to the ingress:
```bash
$ kubectl get ingress
NAME                CLASS    HOSTS            ADDRESS                      PORTS   AGE
halan-app-ingress   <none>   halan.omar.com   172.31.10.133,172.31.8.231   80      106s
```
9. Add the following line to the bottom of the ```/etc/hosts``` file.
```bash
172.31.10.133 halan.omar.com
```
10. Verify that the Ingress controller is directing traffic
```bash
$ curl halan.omar.com/
Halan ROCKS
```
#### Destroy everything whenever you want
```bash
$ docker stop $(docker ps -aq)
$ docker system prune -f
$ docker volume rm $(docker volume ls -q)
$ docker image rm $(docker image ls -q)
$ sudo rm -rf /etc/ceph \
       /etc/cni \
       /etc/kubernetes \
       /opt/cni \
       /opt/rke \
       /run/secrets/kubernetes.io \
       /run/calico \
       /run/flannel \
       /var/lib/calico \
       /var/lib/etcd \
       /var/lib/cni \
       /var/lib/kubelet \
       /var/lib/rancher/rke/log \
       /var/log/containers \
       /var/log/pods \
       /var/run/calico
```