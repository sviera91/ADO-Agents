#!/bin/bash

#parameters
URL=$1
PAT=$2
POOL=$3
AGENT=$4
USER=$5


echo "Updating packages ..."
cd /home/$USER
apt update
apt upgrade -y

echo "--- Update Python ---"
sudo apt-get upgrade -y python3
sudo apt install -y python3-pip

echo "--- Installing Azure CLI ---"
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

echo "--- Installing AWS CLI ---"
sudo apt install unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

echo "--- Installing Docker ---"
sudo apt install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
apt-key fingerprint 0EBFCD88

sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io
sudo usermod -aG docker $USER

echo "--- Installing kubectl ---"
sudo apt update && sudo apt install -y apt-transport-https gnupg2
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl

echo "--- Installing eksctl ---"
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin

echo "--- Installing terraforn ---"
wget https://releases.hashicorp.com/terraform/0.12.25/terraform_0.12.25_linux_amd64.zip
unzip terraform_0.12.25_linux_amd64.zip
sudo mv ./terraform /usr/local/bin/terraform

echo "--- Setting Azure DevOps Agent ---"
wget https://vstsagentpackage.azureedge.net/agent/2.168.2/vsts-agent-linux-x64-2.168.2.tar.gz
sudo mkdir ado-agent && sudo chmod o+w ado-agent && cd ado-agent
sudo tar zxvf /home/$USER/vsts-agent-linux-x64-2.168.2.tar.gz
./config.sh --unattended --url $URL --auth pat --token $PAT --pool $POOL --agent $AGENT --acceptTeeEula
./svc.sh install
./svc.sh start