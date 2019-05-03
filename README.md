kubectl apply -f deploy.yaml 


kubectl apply -f deploy.yaml --record


kubectl rollout status deployments jenkins-deploy


kubectl rollout undo deployment jenkins-deploy --to-revision=1


docker login


cat ~/.docker/config.json


kubectl create secret docker-registry docker  --docker-username=navya3416 --docker-password=XXXXXXX --docker-email=xxxxxxxxxxxx@gmail.com
