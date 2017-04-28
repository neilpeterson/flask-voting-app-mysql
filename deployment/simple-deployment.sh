keyvault=mykeyvault008
keyvaultrg=testkvrg008
vmFront=vmfront

az group create --name $keyvaultrg --location westus

az keyvault create --name $keyvault --resource-group $keyvaultrg --enabled-for-deployment
az keyvault secret set --vault-name $keyvault --name 'sqlpassword' --value 'Password12'

secret=$(az keyvault secret list-versions --vault-name $keyvault --name sqlpassword --query "[?attributes.enabled].id" --output tsv)
vm_secret=$(az vm format-secret --secret "$secret")

az vm create --resource-group $keyvaultrg --name $vmFront --image UbuntuLTS --generate-ssh-keys --custom-data cloud-init-front.txt --secrets "$vm_secret" --debug