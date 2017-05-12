#!/bin/bash

# VM values
resourceGroup="myResourceGroup2"
vmFront="vmfront2"
vmBack="vmback2"

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
  --source-address-prefix "*" \
  --source-port-range "*" \
  --destination-address-prefix "*" \
  --destination-port-range "22" 

# Create back-end vm
az vm create \
  --resource-group $resourceGroup \
  --name $vmBack \
  --vnet-name myVnet \
  --subnet mySubnetBackEnd \
  --nsg "" \
  --image UbuntuLTS \
  --generate-ssh-keys

# configure back
az vm extension set \
  --resource-group $resourceGroup \
  --vm-name $vmBack \
  --name customScript \
  --publisher Microsoft.Azure.Extensions \
  --settings '{"fileUris": ["https://raw.githubusercontent.com/neilpeterson/flask-voting-app/master/deployment/vote-app-back.sh"],"commandToExecute": "./vote-app-back.sh neillocal Password12"}'

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

# configure front
az vm extension set \
  --resource-group $resourceGroup \
  --vm-name $vmFront \
  --name customScript \
  --publisher Microsoft.Azure.Extensions \
  --settings '{"fileUris": ["https://raw.githubusercontent.com/neilpeterson/flask-voting-app/master/deployment/vote-app-front.sh"],"commandToExecute": "./vote-app-front.sh"}'