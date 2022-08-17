

$ErrorActionPreference = "Stop"


# Choose a name for the service principal that contacts azure DNS to present
# the challenge.
$AZURE_CERT_MANAGER_NEW_SP_NAME="k8s-acme-dns"
# This is the name of the resource group that you have your dns zone in.
$AZURE_DNS_ZONE_RESOURCE_GROUP="galaxy"
# The DNS zone name. It should be something like domain.com or sub.domain.com.
$AZURE_DNS_ZONE="dyrvold.dev"

$DNS_SP=$(az ad sp create-for-rbac --name $AZURE_CERT_MANAGER_NEW_SP_NAME --output json)
$AZURE_CERT_MANAGER_SP_APP_ID=$(echo $DNS_SP | jq -r '.appId')
$AZURE_CERT_MANAGER_SP_PASSWORD=$(echo $DNS_SP | jq -r '.password')
$AZURE_TENANT_ID=$(echo $DNS_SP | jq -r '.tenant')
$AZURE_SUBSCRIPTION_ID=$(az account show --output json | jq -r '.id')

az role assignment delete --assignee $AZURE_CERT_MANAGER_SP_APP_ID --role Contributor | Out-null
$DNS_ID=$(az network dns zone show --name $AZURE_DNS_ZONE --resource-group $AZURE_DNS_ZONE_RESOURCE_GROUP --query "id" --output tsv)
az role assignment create --assignee $AZURE_CERT_MANAGER_SP_APP_ID --role "DNS Zone Contributor" --scope $DNS_ID | Out-null

az role assignment list --all --assignee $AZURE_CERT_MANAGER_SP_APP_ID
kubectl create secret generic azuredns-config --from-literal=client-secret=$AZURE_CERT_MANAGER_SP_PASSWORD -n cert-manager

echo "AZURE_CERT_MANAGER_SP_APP_ID: $AZURE_CERT_MANAGER_SP_APP_ID"
echo "AZURE_CERT_MANAGER_SP_PASSWORD: $AZURE_CERT_MANAGER_SP_PASSWORD"
echo "AZURE_SUBSCRIPTION_ID: $AZURE_SUBSCRIPTION_ID"
echo "AZURE_TENANT_ID: $AZURE_TENANT_ID"
echo "AZURE_DNS_ZONE: $AZURE_DNS_ZONE"
echo "AZURE_DNS_ZONE_RESOURCE_GROUP: $AZURE_DNS_ZONE_RESOURCE_GROUP"
