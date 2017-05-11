#!/bin/bash

# VM values
resourceGroup="myResourceGroup4"
vmFront="vmfront4"
vmBack="vmback4"

# Create resource group
az group create --name $resourceGroup --location westus

# Create a virtual network
az network vnet create --resource-group $resourceGroup --name myVnet --subnet-name mySubnet

# Pre-create back-end NSG
az network nsg create --resource-group $resourceGroup --name myBackendNSG
az network nsg rule create --resource-group $resourceGroup --nsg-name myBackendNSG --name mySQL --access Allow --protocol Tcp --direction Inbound --priority 200 --source-address-prefix 10.0.0.4 --source-port-range "*" --destination-address-prefix "*" --destination-port-range 3306
az network vnet subnet create --address-prefix 10.0.1.0/24 --name myBackendSubnet --resource-group $resourceGroup --vnet-name myVnet --network-security-group myBackendNSG

# Create back-end VMs
az vm create --resource-group $resourceGroup --name $vmBack --image UbuntuLTS  --generate-ssh-keys
# az vm create --resource-group $resourceGroup --name $vmBack --image UbuntuLTS --public-ip-address "" --nsg "" --generate-ssh-keys

# configure back
az vm extension set \
  --resource-group $resourceGroup \
  --vm-name $vmBack \
  --name customScript \
  --publisher Microsoft.Azure.Extensions \
  --settings '{"fileUris": ["https://raw.githubusercontent.com/neilpeterson/flask-voting-app/master/deployment/custom-script/vote-app-back.sh"],"commandToExecute": "./vote-app-back.sh"}'

# Create front-end
az vm create --resource-group $resourceGroup --name $vmFront --image UbuntuLTS --vnet-name myVnet --generate-ssh-keys
az vm open-port --port 80 --resource-group $resourceGroup --name $vmFront

# configure front
# az vm extension set \
# --resource-group $resourceGroup \
# --vm-name $vmFront \
# --name customScript \
# --publisher Microsoft.Azure.Extensions \
# --settings '{"fileUris": ["https://raw.githubusercontent.com/neilpeterson/flask-voting-app/master/deployment/custom-script/vote-app-front.sh"],"commandToExecute": "./vote-app-front.sh"}'