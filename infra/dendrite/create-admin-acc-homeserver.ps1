k exec -it $(kubectl get pods -o name -l app=dendrite) -- sh
/usr/bin/create-account -admin -username fredx30 -config /etc/dendrite/dendrite.yaml -url https://homeserver.dyrvold.dev:6443
