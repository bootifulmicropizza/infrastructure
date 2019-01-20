#!/bin/bash

if [ $# -eq 0 ]
then
    echo "Usage:    ./create-cluster.sh <cluster-name>"
    echo "  e.g:    ./create-cluster.sh myNewCluster"
    exit
fi

CLUSTER_NAME=$1
AWS_REGION=eu-west-1
SSL_CERT=arn:aws:acm:eu-west-1:408612431374:certificate/d5f175d0-86d1-45a8-82f1-ad921afaae0b

function createCluster() {
	echo "Create cluster $CLUSTER_NAME"

	# Create stack from CF template
	aws cloudformation create-stack --stack-name $CLUSTER_NAME --parameters ParameterKey=ClusterName,ParameterValue=$CLUSTER_NAME --template-body file://bootifulmicropizza_stack.yml --region $AWS_REGION --capabilities CAPABILITY_IAM --disable-rollback

	# Wait for cluster to be created
	waitForClusterCreateComplete

	# Update the local kubeconfig
	aws eks update-kubeconfig --name $CLUSTER_NAME --region $AWS_REGION

	# Get the NodeInstanceRole from the CF exports and edit the aws-auth-cm.yaml file to allow the nodes to register in the K8S cluster.
	NODE_INSTANCE_ROLE=`aws cloudformation list-exports --region $AWS_REGION --query "Exports[?Name=='$CLUSTER_NAME-NodeInstanceRole'].Value" --output text`

	# Update the k8s config to allow the nodes to join the cluster
	cat aws-auth-cm.yaml | sed "s#ROLE_ARN#$NODE_INSTANCE_ROLE#g" | kubectl create -f -

	# Register admin account
	kubectl apply -f eks-admin-service-account.yaml

	# Install various admin apps
	kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v1.10.1/src/deploy/recommended/kubernetes-dashboard.yaml
	kubectl apply -f https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/influxdb/heapster.yaml
	kubectl apply -f https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/influxdb/influxdb.yaml
	kubectl apply -f https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/rbac/heapster-rbac.yaml

	# Install ingress
	kubectl apply -f ingress/mandatory.yaml
	cat ingress/service-l7.yaml | sed "s#SSL_CERT#$SSL_CERT#g" | kubectl apply -f -
	kubectl apply -f ingress/patch-configmap-l7.yaml

	# Get the ELB name for the ingress
	echo "Waiting for the ELB to come up..."
	end=$((SECONDS+120))
	while [[ $SECONDS -lt $end &&  $INGRESS_ELB == '' ]]; do
		INGRESS_ELB=`kubectl get service ingress-nginx --namespace ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'`
	done

	# Update route53
	echo "Updating route53...$INGRESS_ELB"
	JSON=$(cat route53.json | sed "s#INGRESS_ELB#$INGRESS_ELB#g")
	aws route53 change-resource-record-sets --hosted-zone-id Z3TH6E5MZ6R1K6 --cli-input-json "$JSON"

	# Install dummy webserver pod (simple page for pizza domain to check ingress is working)
	kubectl apply -f nginx/
}

function waitForClusterCreateComplete {
	echo "Waiting for cluster $CLUSTER_NAME creation...."
	aws cloudformation wait stack-create-complete --stack-name $CLUSTER_NAME

	if [ "$?" != "0" ]; then
		echo "ERROR: Cluster $CLUSTER_NAME failed to create"
		exit 1
	fi

	echo "Cluster $CLUSTER_NAME" created.""
}

createCluster $@
