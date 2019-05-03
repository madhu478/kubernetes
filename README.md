kubectl apply -f deploy.yaml/n
kubectl apply -f deploy.yaml --record/n
kubectl rollout status deployments jenkins-deploy
kubectl rollout undo deployment jenkins-deploy --to-revision=1
kubectl create secret docker-registry docker  --docker-username=navya3416 --docker-password=XXXXXXX --docker-email=bejawadanavya@gmail.com                                                                       

