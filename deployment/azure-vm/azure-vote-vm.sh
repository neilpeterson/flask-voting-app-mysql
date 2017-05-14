#!/bin/bash

# MySQL values
user="dbuser"
password="Password12"

# VM values
resourceGroup="myResourceGroup"
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

# Configure back-end
az vm extension set \
  --resource-group $resourceGroup \
  --vm-name $vmBack \
  --name customScript \
  --publisher Microsoft.Azure.Extensions \
  --settings '{"fileUris": ["https://raw.githubusercontent.com/neilpeterson/flask-voting-app/master/deployment/vote-app-back.sh"]}' \
  --protected-settings '{"commandToExecute": "./vote-app-back.sh '$user' '$password'"}'

# Create front-end
az vm create \
  --resource-group $resourceGroup \
  --name $vmFront \
  --vnet-name myVnet \
  --subnet mySubnetFrontEnd \
  --nsg myNSGFrontEnd \
  --public-ip-address myFrontEndIP \
  --image UbuntuLTS \
  --generate-ssh-keys

# Front-end NSG rule
az network nsg rule create \
  --resource-group $resourceGroup \
  --nsg-name myNSGFrontEnd \
  --name http \
  --access Allow \
  --protocol Tcp \
  --direction Inbound \
  --priority 100 \
  --source-address-prefix "*" \
  --source-port-range "*" \
  --destination-address-prefix "*" \
  --destination-port-range "80" 

# Get internal IP address of MySQL VM
ip=$(az vm list-ip-addresses --resource-group $resourceGroup --name $vmBack --query [0].virtualMachine.network.privateIpAddresses[0] -o tsv)

# Configure front-end
az vm extension set \
  --resource-group $resourceGroup \
  --vm-name $vmFront \
  --name customScript \
  --publisher Microsoft.Azure.Extensions \
  --settings '{"fileUris": ["https://raw.githubusercontent.com/neilpeterson/flask-voting-app/master/deployment/vote-app-front.sh"]}' \
  --protected-settings '{"commandToExecute": "./vote-app-front.sh '$user' '$password' '$ip'"}'