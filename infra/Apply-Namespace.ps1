
param()


kubectl apply -f ingress-lb.yaml

helm repo add jetstack https://charts.jetstack.io
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace `
    --version v1.10.1 --set installCRDs=true

Write-host "Create credentials from zerossl."
$KID = Read-host "EAB_KID: "
$HMAC = Read-host "EAB_HMAC_Key: " -AsSecureString | ConvertFrom-SecureString -AsPlainText
kubectl create secret generic zero-ssl-eab-credentials `
  --from-literal "EAB_KID=${KID}" `
  --from-literal "EAB_HMAC_KEY=${HMAC}" `
  -n cert-manager

$clusterissuer = Get-Content ./clusterissuer-zerossl.yaml
$clusterissuer.Replace('EAB_KID', $KID)
$clusterissuer.Replace('EAB_HMAC_KEY', $HMAC)
$clusterissuer | kubectl apply -f -

kubectl apply -f ./element-web.yaml


## Setup Dendrite (Matrix homeserver)
helm install dendrite-postgresql bitnami/postgresql -f dendrite/dendrite-values-postgresql.yaml -n dendrite
k apply -f dendrite/dendrite-config.yaml
k apply -f dendrite/dendrite.yaml
