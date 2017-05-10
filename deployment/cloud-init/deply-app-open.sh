#!/bin/bash

# VM values
resourceGroup="myResourceGroup"
vmFront="vmfront"
vmBack="vmback"

# Create VM resource group
az group create --name $resourceGroup --location westus

# Create a virtual network
az network vnet create --resource-group $resourceGroup --name myVnet --subnet-name mySubnet

# Create VM front
az vm create --resource-group $resourceGroup --name $vmFront --image UbuntuLTS --vnet-name myVnet --generate-ssh-keys --custom-data cloud-init-front.txt

# Open port 80
az vm open-port --port 80 --resource-group $resourceGroup --name $vmFront

# Pre-create back end NSG
az network nsg create --resource-group $resourceGroup --name myBackendNSG

# Add backend subnet
az network vnet subnet create --address-prefix 10.0.1.0/24 --name myBackendSubnet --resource-group $resourceGroup --vnet-name myVnet --network-security-group myBackendNSG

# Create VM back
az vm create --resource-group $resourceGroup --name $vmBack --image UbuntuLTS --generate-ssh-keys --custom-data cloud-init-back.txt

# Open port 3306 on back end NSG
az vm open-port --port 3306 --resource-group $resourceGroup --name $vmBack