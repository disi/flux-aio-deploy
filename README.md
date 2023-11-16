# AWX deployment with Flux
## Summary
This guide will deploy AWX to a Kubernetes cluster via Flux.

Flux is a CI/CD service, which works with Helm charts to deploy containers on Kubernetes. The desired state of the containers is hosted in a Git repostiory (check every minute).
All configuration of the Helm releases for containers should be made in the Git repository, Flux checks the current cluster state about every minute.
### Services involved
- AWX is an Ansbile Automation Platform.
- KubeClarity is a dashboard to Kubernetes to show/scan vulnerabilties within the cluster.
- Kubernetes-Dashboard is a dashboard to Kubernetes.
- Weave-GitOps is a dashboard to Flux.
- Flux is a CI/CD system to apply the state of the cluster and upgrade container images.
- Timoni is a kubernetes deployment tool.
- NGINX Ingress Controller is a service to expose containers to the network.
- MetalLB is a load balancer to assign IPs to Ingress Controllers.
- Kubernetes is a platform to run containerized images.
### Requirements
- Kubernetes cluster with internet access.
- Access to the master node of the Kubernetes cluster.
- A copy of this Git Repository.
- PSQL DB is recommended.
## Install
### Considerations
- Values should only need to be changed in the kustomization.yaml files.
- Changes to the infrastructure may take several minutes for Flux to update.
- Some kustomizations to containers can only be applied during creation or start of the container. Rebooting the cluster or deleting the container/service should apply those new values.
- The current configuration deploys always the latest releases and checks every 12 hours for new versions, this behaviour can be changed in the yaml files for the differnet images.
- This deployment is intended to work without CNI. If you have already a CNI installed, remove Flannel from the core-infrastructure.
### 1. Change values for the deployment in the Git repository
#### Layout of the repostiory
The comments mark the files where changes should be made.
```
HOMEAIO
├── README.md
├── apps
│   ├── awx
│   │   ├── configs
│   │   │   ├── awx.yaml
│   │   │   ├── ingress.yaml
│   │   │   ├── kustomization.yaml # change the values for the AWX deployment
│   │   │   ├── pv.yaml
│   │   │   ├── pvc.yaml
│   │   │   └── tls # change the tls certs for AWX
│   │   │       ├── tls.crt
│   │   │       └── tls.key
│   │   └── systems
│   │       ├── awx-operator.yaml
│   │       └── kustomization.yaml
│   └── basic
│       ├── kubeclarity.yaml
│       ├── kubernetes-dashboard.yaml
│       ├── kustomization.yaml # change the values for the dashboards
│       ├── tls # change the tls certs for the dashboards
│       │   ├── tls.crt
│       │   └── tls.key
│       └── weave-gitops.yaml
├── core-infrastructure
│   ├── configs
│   │   ├── kustomization.yaml # change the metallb IP range
│   │   └── metallb-controller-config.yaml
│   └── systems
│       ├── flannel-cni.yaml
│       ├── kustomization.yaml
│       └── metallb-controller.yaml
├── flux-aio.cue # timoni deployment bundle - change Flux version and GIT URLs
└── infrastructure
    ├── configs
    │   ├── kustomization.yaml # change the kubernetes dashboard hostname
    │   └── nginx-controller-config.yaml
    └── systems
        ├── kustomization.yaml
        └── nginx-controller.yaml
```
#### Flow of the deployment
- First timoni will deploy the kustomization in this order: core-infrastructure -> infrastructure -> apps/basic -> apps/awx
- Afterwards the AWX Operator will deploy AWX.
### 2. Prepare the databases and users on the Postgres instance
- PostGreSQL DBs required/recommended for AWX and kubeClarity
```
$ sudo -i -u postgres
postgres$ createdb awx
postgres$ createdb kubeclarity
postgres$ createuser --createdb awx
postgres$ createuser --createdb kubeclarity
postgres$ psql
postgres# grant all privileges on database awx to awx;
postgres# grant all privileges on database kubeclarity to kubeclarity;
postgres# \q
postgres$ exit
```
- To change the passwords for users in psql
```
$ sudo -i -u postgres
postgres$ psql
postgres# ALTER ROLE awx
postgres# WITH PASSWORD 'awxawx';
postgres# ALTER ROLE kubeclarity
postgres# WITH PASSWORD 'kubeclarity';
postgres# \q
postgres$ exit
```
### 3. AWX and cluster deployment on the master node
#### \[Optional\] Prepare the project cache folder (AWX projects should be hosted on an external Git repostiory).
```
$ sudo mkdir -p /data/projects
$ sudo chown 1000:0 /data/projects
```
#### Flux deployment via timoni
You will need to update the file flux-aio.cue with the URL to your GIT repository.
Download the timoni binary from https://github.com/stefanprodan/timoni/releases
```
$ wget -qO- https://github.com/stefanprodan/timoni/releases/download/v0.16.0/timoni_0.16.0_linux_amd64.tar.gz | tar xvz
$ sudo mv timoni /usr/locl/bin/
# /usr/local/bin/timoni completion bash > /etc/bash_completion.d/timoni
$ sudo ln -s /usr/local/bin/timoni /usr/bin/timoni
```
Custom root authority (if not you need to edit the flux-aio.cue file and remove the line 'ca: string @timoni(runtime:string:GIT_CA)' for every repository).

More examples for different Git repositories: https://github.com/stefanprodan/flux-aio
```
$ export GIT_CA=$(cat ~/certs/rootCA.pem)
```
GIT credentials.
```
$ export GIT_TOKEN="abcdefgh12345678"
```
Let timoni deploy the bundle from flux-aio.cue in this repository.
```
$ timoni bundle apply -f ./flux-aio.cue --runtime-from-env
```
#### Wait for the cluster to build
```
$ watch kubectl get pods,svc,ingress -A
```
#### You will need to have some DNS records for your hostnames to point to the NGINX controller IP (EXTERNAL-IP).
Command to get the EXTERNAL-IP.
```
$ kubectl get svc ingress-nginx-controller -n ingress-nginx
```
Example entry into /etc/hosts.
```
#AWX replace <external-ip>
<external-ip> awx.home k8s.home weave.home kubeclarity.home
```
### 5. Logon to the different dashboards (hostnames with default values)
With the DNS records in place you can access the different web services.
- https://awx.home - AWX
- https://weave.home - Weave-GitOps
- https://k8s.home - Kubernetes
- https://kubeclarity.home - kubeClarity
#### Default users and passwords:
- Weave-GitOps: admin/flux
- AWX: admin/awxawx
## 4. Set up the Flux CLI on the master node
```
$ curl -s https://fluxcd.io/install.sh | sudo bash
$ source <(flux completion bash)
# /usr/local/bin/flux completion bash > /etc/bash_completion.d/flux
$ sudo ln -s /usr/local/bin/flux /usr/bin/flux
$ curl --silent --location "https://github.com/weaveworks/weave-gitops/releases/download/v0.24.0/gitops-$(uname)-$(uname -m).tar.gz" | tar xz -C /tmp
$ sudo mv /tmp/gitops /usr/local/bin/
$ sudo ln -s /usr/local/bin/gitops /usr/bin/gitops
```
### Useful Flux CLI commands
- Initiate a manual git sync for Flux.
```
$ flux get sources all
$ flux reconcile source git cluster-apps-basic
```
- Watch events is good for troubleshooting errors (like weave on commandline).
```
$ flux events -w
```
- Check the status and versions of all deployments.
```
$ flux get helmreleases --all-namespaces
```
- Check the kustomizations for all deployments.
```
$ flux get kustomizations --all-namespaces
```