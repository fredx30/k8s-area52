snap install microk8s
# TODO add setup certificate for custom dns.
sudo usermod -a -G microk8s fredrik
sudo chown -f -R fredrik ~/.kube
microk8s enable dns
microk8s enable metallb
microk8s enable ingress
microk8s enable metrics-server
microk8s enable hostpath-storage
