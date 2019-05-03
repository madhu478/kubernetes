kubectl apply -f deploy.yaml
kubectl apply -f deploy.yaml --record
kubectl rollout status deployments jenkins-deploy
kubectl rollout undo deployment jenkins-deploy --to-revision=1

