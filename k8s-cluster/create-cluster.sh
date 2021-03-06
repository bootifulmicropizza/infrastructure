#!/bin/bash

if [ $# -eq 0 ]
then
    echo "Usage:    ./create-cluster.sh <cluster-name>"
    echo "  e.g:    ./create-cluster.sh myNewCluster"
    exit
fi

CLUSTER_NAME=$1
STACK_NAME=$1-eks-cluster
AWS_REGION=eu-west-1
SSL_CERT=arn:aws:acm:eu-west-1:408612431374:certificate/d5f175d0-86d1-45a8-82f1-ad921afaae0b
DASHBOARD_VERSION=1.10.1

function createCluster() {
	echo "Creating cluster $CLUSTER_NAME"

	# Create stack from CF template
	aws cloudformation create-stack --stack-name $STACK_NAME --parameters ParameterKey=ClusterName,ParameterValue=$CLUSTER_NAME --template-body file://bootifulmicropizza_stack.yml --region $AWS_REGION --capabilities CAPABILITY_IAM --disable-rollback

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

	# Install Dashboard
	kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v$DASHBOARD_VERSION/src/deploy/recommended/kubernetes-dashboard.yaml

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
}

function waitForClusterCreateComplete {
	echo "Waiting for cluster $CLUSTER_NAME creation...."
	aws cloudformation wait stack-create-complete --stack-name $STACK_NAME

	if [ "$?" != "0" ]; then
		echo "ERROR: Cluster $CLUSTER_NAME failed to create"
		exit 1
	fi

	echo "Cluster $CLUSTER_NAME" created.""
}

createCluster $@
