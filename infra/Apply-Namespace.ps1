helm repo add jetstack https://charts.jetstack.io
helm repo update
helm upgrade --install `
  cert-manager jetstack/cert-manager `
  --namespace cert-manager `
  --create-namespace `
  --version v1.15.3 `
  --set crds.enabled=true `
  --set ingressShim.defaultIssuerName=dyrvold-dev-zerossl `
  --set ingressShim.defaultIssuerKind=ClusterIssuer


Write-host "Create credentials from zerossl."
$KID = Read-host "EAB_KID: "
$HMAC = Read-host "EAB_HMAC_Key: "
kubectl create secret generic zero-ssl-eab-credentials `
  --from-literal "EAB_KID=${KID}" `
  --from-literal "EAB_HMAC_KEY=${HMAC}" `
  -n cert-manager

k apply -f clusterissuer-zerossl.yaml
