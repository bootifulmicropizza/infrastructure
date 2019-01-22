#!/bin/bash

if [ $# -eq 0 ]
then
    echo "Usage:    ./delete-cluster.sh <cluster-name>"
    echo "  e.g:    ./delete-cluster.sh myCluster"
    exit
fi

CLUSTER_NAME=$1
STACK_NAME=$1-eks-cluster
AWS_REGION=eu-west-1

function deleteCluster() {
	echo "Deleting cluster $CLUSTER_NAME"

	# Delete the ELB (to free up the network interfaces so the VPC can be deleted)
	INGRESS_ELB=`kubectl get service ingress-nginx --namespace ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'`
	echo "Got INGRESS_ELB $INGRESS_ELB"
	LOAD_BALANCER_NAME=`aws elb describe-load-balancers --query "LoadBalancerDescriptions[?CanonicalHostedZoneName=='$INGRESS_ELB'].LoadBalancerName" --output text`
	echo "Deleting ELB $LOAD_BALANCER_NAME"
	aws elb delete-load-balancer --load-balancer-name $LOAD_BALANCER_NAME

	# Delete stack from CF
	aws cloudformation delete-stack --stack-name $STACK_NAME --region $AWS_REGION
}

deleteCluster $@
