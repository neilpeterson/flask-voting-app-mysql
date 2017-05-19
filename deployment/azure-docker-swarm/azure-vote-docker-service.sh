#!/bin/bash

# MySQL values
user="dbuser"
password="Password12"

# VM values
resourceGroup="myResourceGroupSwarm"
vmBack="vmback"

# Create resource group
az group create --name $resourceGroup --location eastus

# Create AD service principle
scope=$(az group show --name $resourceGroup --query "id" -o tsv)
servicePrincipal=$(az ad sp create-for-rbac --role="Contributor" --scopes=$scope)
id=$(echo $servicePrincipal | cut -d '"' -f 4)
secret=$(echo $servicePrincipal | cut -d '"' -f 16)

# Get SSH public key
ssh=$(cat ~/.ssh/id_rsa.pub)

# Deploy docker swarm
az group deployment create \
  --name dockertest \
  --resource-group $resourceGroup \
  --template-uri https://download.docker.com/azure/stable/Docker.tmpl \
  --parameters "{\"enableSystemPrune\": {\"value\": \"yes\"},\"managerCount\": {\"value\": 1},\"managerVMSize\": {\"value\": \"Standard_D2_v2\"},\"swarmName\": {\"value\": \"dockerswarm\"},\"workerCount\": {\"value\": 3},\"workerVMSize\": {\"value\": \"Standard_D2_v2\"},\"sshPublicKey\": {\"value\": \"$ssh\"},\"adServicePrincipalAppID\": {\"value\": \"$id\"},\"adServicePrincipalAppSecret\": {\"value\": \"$secret\"}}"

# Pre-create back-end NSG
az network nsg create --resource-group $resourceGroup --name myNSGBackEnd

az network nsg rule create \
  --resource-group $resourceGroup \
  --nsg-name myNSGBackEnd \
  --name MySQL \
  --access Allow \
  --protocol Tcp \
  --direction Inbound \
  --priority 200 \
  --source-address-prefix 10.0.0.0/8 \
  --source-port-range "*" \
  --destination-address-prefix "*" \
  --destination-port-range "3306"

az network nsg rule create \
  --resource-group $resourceGroup \
  --nsg-name myNSGBackEnd \
  --name denyAll \
  --access Deny \
  --protocol Tcp \
  --direction Inbound \
  --priority 300 \
  --source-address-prefix "*" \
  --source-port-range "*" \
  --destination-address-prefix "*" \
  --destination-port-range "*"

# Create back-end subnet
vnet=$(az network vnet list --resource-group $resourceGroup --query [0].['name'] -o tsv)

az network vnet subnet create \
  --resource-group $resourceGroup \
  --vnet-name $vnet \
  --name mySubnetBackEnd \
  --address-prefix 172.16.0.0/24 \
  --network-security-group myNSGBackEnd

# Create back-end vm
az vm create \
  --resource-group $resourceGroup \
  --name $vmBack \
  --vnet-name $vnet \
  --subnet mySubnetBackEnd \
  --public-ip-address "" \
  --image UbuntuLTS \
  --generate-ssh-keys

# configure back-end vm
az vm extension set \
  --resource-group $resourceGroup \
  --vm-name $vmBack \
  --name customScript \
  --publisher Microsoft.Azure.Extensions \
  --settings '{"fileUris": ["https://raw.githubusercontent.com/neilpeterson/flask-voting-app/master/deployment/vote-app-back.sh"]}' \
  --protected-settings '{"commandToExecute": "./vote-app-back.sh '$user' '$password'"}'

# Start Docker service
ip=$(az network public-ip list --query "[?contains(name, 'dockerswarm-externalSSHLoadBalancer-public-ip')].[ipAddress]" -o tsv)
backendip=$(az vm list-ip-addresses --resource-group $resourceGroup --name $vmBack --query "[0].[virtualMachine.network.privateIpAddresses[0]]" -o tsv)
ssh -o "StrictHostKeyChecking no" -p 50000 -fNL localhost:2374:/var/run/docker.sock docker@$ip
docker -H localhost:2374 service create --name demoService -p 80:80 --replicas=2 neilpeterson/azure-vote-front $user $password $backendip

echo "Run 'docker -H localhost:2374 service ls' to see service status"