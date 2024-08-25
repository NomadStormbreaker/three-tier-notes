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