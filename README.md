# DevOps-Challenge
#### This challenge is divided into two parts:
## Part-1: Programming
#### Create a simple REST API using your preferred programming language that does the following:
- It responds to the URL like http://host-ip/ and returns: Hello World, I'm Omar
- responds to the URL like http://host-ip/?n=x and returns n*n
- It responds to the URL like http://host-ip/ip with the IP address of the client making the request and save that IP address on Postgres
- It responds to the URL like http://host-ip/allips with all of the saved IP addresses after retrieving it from Postgres.
- The app is served via a wsgi handler. Like uWSGI
- The Application is Dockerized.
## Part-2: Deployment
#### there are several options to deploy the app
- #### [ Using Docker ](#option1)
- #### [ Kubernetes deployment ](#option2)
- #### [ On-premise deployment ](#option3)
## <a name="option1"> Using Docker</a>
#### in this option we will use sqlite database
1. [Install Docker](https://docs.docker.com/engine/install/)
2. Clone this repo
```bash
git clone https://github.com/omarelsheekh/DevOps-Challenge
```
3. Build the docker image
```bash
docker build -t <image name> DevOps-Challenge/app/
```
4. Run the docker image
```bash
docker run -e "db_type=sqlite" -dp 5000:5000 -p 9191:9191 <image name>
```

## <a name="option2"> Kubernetes deployment</a>

1. [Install Docker](https://docs.docker.com/engine/install/) on all machines
2. [Install kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) on machines you will run commands from
3. Setup a K8s cluster, you can pick one of these options
    - [create a new cluster using Rancher](/rancher-cluster.pdf)
    - [create a new cluster using minikube](https://minikube.sigs.k8s.io/docs/start/)
    , make sure to enable the NGINX Ingress controller in minikube
      ```bash
      minikube addons enable ingress
      ```
4. Install helm on machines have kubectl installed
    ```bash
    curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
    ```
5. Clone this repo
    ```bash
    git clone https://github.com/omarelsheekh/DevOps-Challenge
    ```
6. Build the docker image
    ```bash
    docker build -t <image name> DevOps-Challenge/app/
    ```
7. move to helm-chart directory
    ```bash
    cd DevOps-Challenge/helm-chart
    ```
8. Run the app helm chart
    ```bash
    helm install --set app.image=<image name> app .
    ```
    - warning: if you running it on minikube you have to set affinity to "" 
        ```bash
        helm install --set app.affinity="" --set postgresql.affinity=""  --set app.image=<image name> myapp .
        ```
9. Verify the IP addresses is set to the ingress:
    ```bash
    $ kubectl get ingress
    NAME                CLASS    HOSTS   ADDRESS        PORTS   AGE
    myapp-app-ingress   <none>   *       192.168.49.2   80      9m13s
    ```
<!-- 10. Add the following line to the bottom of the ```/etc/hosts``` file.
```bash
172.31.10.133 halappan.omar.com
``` -->
10. Verify that the Ingress controller is directing traffic
    ```bash
    $ curl 192.168.49.2/
    Hello World, I\'m Omar
    ```
<!-- #### Destroy everything whenever you want
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
``` -->
## <a name="option3"> On-premise deployment </a>
#### Using the automation tool (Terraform) prepare a FULLY provisioned environment.
#### This automation should:
- Provision 3 nodes on Azure, On these 3 nodes deploy:
  1. The API
  2. DB Master (PostgreSQL)
  3. DB Slave (PostgreSQL) and Setup master-slave (streaming replication) PostgreSQL between node 2 and 3.
- Deploying the Dockerized API on the App node
### Getting Started

1. [Install Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
2. [Install azure Cli](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
3. log in to your azure account 
    ```bash
    az login
    ```
4. Make Sure that your subscription is active 
    ```bash
    $ az account list

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
