
param()


k apply -f ingress-lb.yaml

helm repo add jetstack https://charts.jetstack.io
helm repo update

helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace `
    --version v1.9.1 --set installCRDs=true

Write-host "Create credentials from zerossl."
$KID = Read-host "EAB_KID: "
$HMAC = Read-host "EAB_HMAC_Key: " -AsSecureString | ConvertFrom-SecureString -AsPlainText
kubectl create secret generic zero-ssl-eab-credentials `
  --from-literal "EAB_KID=${KID}" `
  --from-literal "EAB_HMAC_KEY=${HMAC}" `
  -n cert-manager

k apply -f element.ps1
