#!/bin/bash

# MySQL values
user="dbuser"
password="Password12"

# VM values
resourceGroup="myswarm"
vmFront="vmfront"
vmBack="vmback"

# Create resource group
az group create --name $resourceGroup --location eastus

# Create a virtual network and front-end subnet
az network vnet create \
  --resource-group $resourceGroup \
  --name myVnet \
  --address-prefix 10.0.0.0/16 \
  --subnet-name mySubnetFrontEnd \
  --subnet-prefix 10.0.1.0/24

# Create back-end subnet
az network vnet subnet create \
  --resource-group $resourceGroup \
  --vnet-name myVnet \
  --name mySubnetBackEnd \
  --address-prefix 10.0.2.0/24

# Pre-create back-end NSG
az network nsg create --resource-group $resourceGroup --name myNSGBackEnd

az network vnet subnet update \
  --resource-group $resourceGroup \
  --vnet-name myVnet \
  --name mySubnetBackEnd \
  --network-security-group myNSGBackEnd

az network nsg rule create \
  --resource-group $resourceGroup \
  --nsg-name myNSGBackEnd \
  --name SSH \
  --access Allow \
  --protocol Tcp \
  --direction Inbound \
  --priority 100 \
  --source-address-prefix 10.0.1.0/24 \
  --source-port-range "*" \
  --destination-address-prefix "*" \
  --destination-port-range "22" 

az network nsg rule create \
  --resource-group $resourceGroup \
  --nsg-name myNSGBackEnd \
  --name MySQL \
  --access Allow \
  --protocol Tcp \
  --direction Inbound \
  --priority 200 \
  --source-address-prefix 10.0.1.0/24 \
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

# Create back-end vm
az vm create \
  --resource-group $resourceGroup \
  --name $vmBack \
  --vnet-name myVnet \
  --subnet mySubnetBackEnd \
  --public-ip-address "" \
  --nsg "" \
  --image UbuntuLTS \
  --generate-ssh-keys

# configure back
az vm extension set \
  --resource-group $resourceGroup \
  --vm-name $vmBack \
  --name customScript \
  --publisher Microsoft.Azure.Extensions \
  --settings '{"fileUris": ["https://raw.githubusercontent.com/neilpeterson/flask-voting-app/master/deployment/vote-app-back.sh"]}' \
  --protected-settings '{"commandToExecute": "./vote-app-back.sh '$user' '$password'"}'

# Docker Swarm Scratch - will clean up

# az ad app create --display-name dockerswarm --homepage http://twodockerswarm.com --identifier-uris http://twodockerswarm.com
# appId=$(az ad app list --display-name dockerswarm --query [0].appId -o tsv)
# az ad sp create-for-rbac -name http://twodockerswarm.com

# ssh=$(cat ~/.ssh/id_rsa.pub)

# Deploy docker swarm
az group deployment create \
  --name dockertest \
  --resource-group dockerdemo \
  --template-uri https://download.docker.com/azure/stable/Docker.tmpl \
  --parameters @docker-swarm-parameters.json

# az network lb inbound-nat-rule create --resource-group dockerswarm --lb-name externalSSHLoadBalancer --name dockertls --protocol Tcp --backend-port 2376 --frontend-port 2376 --frontend-ip-name default

ssh -p 50000 -fNL localhost:2374:/var/run/docker.sock docker@13.64.65.75
docker -H localhost:2374 images
docker -H localhost:2374 pull neilpeterson/nepetersv1
