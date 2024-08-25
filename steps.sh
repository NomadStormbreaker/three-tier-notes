###################################### JENKINS ######################################
# Create a Jenkins Server
# Refer jenkins.tf in terraform/vscode

sudo cat /var/lib/jenkins/secrets/initialAdminPassword

# Install Plugins
# Docker Pipeline agent
# Manage Jenkins - Plugins - Docker Pipeline

# Setup Credentials
# 1. Github -> "github-cred" Type: secret text
# 2. Dockerhub -> "dockerhub-creds" type: username and password


# Create 2 Pipeline projects > backend pipeline and frontend pipeline
# Configuration of Frontend:
#   Pipeline script from SCM
#   Git
#   Repository URL
#   main Branch
#   Script Path : Application-Code/frontend/Jenkinsfile

# Configuration of Backend:
#   Pipeline script from SCM
#   Git
#   Repository URL
#   main Branch
#   Script Path : Application-Code/backend/Jenkinsfile

##################################### KUBERNETES CLUSTER ###########################

# Open Cloudshell in AWS

# Download the latest version of eksctl binary for the current OS architecture
# and extract it to the /tmp directory.
curl --silent --location \
"https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp

# Move the extracted eksctl binary from /tmp to /usr/local/bin so it can be
# executed from anywhere on the system.
sudo mv /tmp/eksctl /usr/local/bin

# Verify the installation by checking the version of eksctl.
eksctl version

# Create an Amazon EKS cluster with the specified configuration.
# - `--name test-eks-cluster`: Name of the EKS cluster.
# - `--version 1.30`: Kubernetes version for the cluster.
# - `--region ap-south-1`: AWS region where the cluster will be created.
# - `--nodegroup-name eks-worker-nodegroup`: Name of the node group.
# - `--node-type t4g.small`: Instance type for the nodes in the node group.
# - `--nodes 2`: Number of nodes to create in the node group.

eksctl create cluster \
  --name three-tier-dev \
  --version 1.30 \
  --region us-east-1 \
  --nodegroup-name eks-worker-nodegroup \
  --node-type t3.medium \
  --nodes 2

# Once the Cluster is created, deploy the yaml files manually first
# 1. Create namspace for three-tier
kubectl create namespace three-tier

# 2. Install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

helm version

# 3. Deploy Ingress controller
# a. Ingress Controller
curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.5.4/docs/install/iam_policy.json

aws iam create-policy \
 --policy-name AWSLoadBalancerControllerIAMPolicy \
 --policy-document file://iam_policy.json

eksctl utils associate-iam-oidc-provider --region=us-east-1 --cluster=three-tier-dev --approve

eksctl create iamserviceaccount \
  --cluster=three-tier-dev \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --role-name AmazonEKSLoadBalancerControllerRole \
  --attach-policy-arn=arn:aws:iam::654654319143:policy/AWSLoadBalancerControllerIAMPolicy \
  --approve

helm repo add eks https://aws.github.io/eks-charts
helm repo update eks

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  --namespace kube-system \
  --set clusterName=three-tier-dev \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set region=us-east-1 \
  --set vpcId=vpc-087d8907b53aa9d63 #edit this after cluster gets created

kubectl get deployment -n kube-system aws-load-balancer-controller


# 4. Deploy YAML files manually first in this order
# Database PV
# Database PVC
# Database Secret
# Database Deployment
# Database Service
# Backend Deployment
# Backend Service
# Frontend Deployment # edit the backend url as Load Balancer DNS
# Frontend Service
# Ingress YAML

# If the notes doesnt work, reapply the frontend deployment and Ingress YAML

################################## ARGO CD IN KUBERNETES #################################

# Install ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Change the ArgoCD server to load balancer
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
# Once there is a load balancer in AWS, open the link, it will unsafe proceed

# Username: admin
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 --decode
# Above command will give the password

# Now create two applications in ArgoCD - one for frontend and one for backend
# Frontend #
# 1. New Application
# 2. Application Name: three-tier-app-frontend
# 3. Project Name: default
# 4. Sync Policy: Automatic and Select Self Heal
# 5. Repository URL: https://github.com/NomadStormbreaker/three-tier-notes
# 6. Path: k8s-manifests/frontend
# 7. Cluster URL: https://kubernetes.default.svc
# 8. Namespace: three-tier
# CREATE

# Backend #
# 1. New Application
# 2. Application Name: three-tier-app-backend
# 3. Project Name: default
# 4. Sync Policy: Automatic and Select Self Heal
# 5. Repository URL: https://github.com/NomadStormbreaker/three-tier-notes
# 6. Path: k8s-manifests/fbackend
# 7. Cluster URL: https://kubernetes.default.svc
# 8. Namespace: three-tier
# CREATE

# Make some change in Repo and build the Pipeline, check if ArgoCD deploys it automatically




##################################33 DELETION OF RESOURCES #####################################
# Delete ARGO CD applications
kubectl delete application three-tier-app-frontend -n argocd
kubectl delete application three-tier-app-backend -n argocd

# Delete Argo CD Installation
kubectl delete namespace argocd

eksctl delete cluster --name three-tier-dev --region us-east-1
