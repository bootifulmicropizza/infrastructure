#!/bin/bash

echo "Deploying Jenkins"

kubectl create -f k8s/k8s-namespace.yaml
kubectl create -f k8s/k8s-volume.yaml
kubectl create -f k8s/k8s-roles.yaml
kubectl create -f k8s/k8s-secrets.yaml
kubectl create -f k8s/k8s-service.yaml
kubectl create -f k8s/k8s-deployment.yaml
kubectl create -f k8s/k8s-ingress.yaml

kubectl rollout status deployment/jenkins --namespace jenkins

# Get the ELB name for the service
echo "Waiting for the ELB to come up..."
end=$((SECONDS+120))
while [[ $SECONDS -lt $end &&  $ELB == '' ]]; do
	ELB=`kubectl get service jenkins --namespace jenkins -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'`
done

# Update route53
echo "Updating route53..."
JSON=$(cat route53.json | sed "s#JENKINS_ELB#$ELB#g")
aws route53 change-resource-record-sets --hosted-zone-id Z3TH6E5MZ6R1K6 --cli-input-json "$JSON"

# Get Jenkins admin password
echo "Jenkins is up!"
JENKINS_POD=$(kubectl get po -o jsonpath="{range .items[*]}{@.metadata.name}{end}" --namespace jenkins)
JENKINS_PWD=$(kubectl exec $JENKINS_POD -c jenkins cat /var/jenkins_home/secrets/initialAdminPassword --namespace jenkins)
echo "Jenkins init admin password: $JENKINS_PWD"


# Setup slaves

# TODO
