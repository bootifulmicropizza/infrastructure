#!/bin/bash

if [ $# -eq 0 ]
then
    echo "Usage:    ./update-cluster.sh <cluster-name>"
    echo "  e.g:    ./update-cluster.sh myNewCluster"
    exit
fi

CLUSTER_NAME=$1
STACK_NAME=$1-eks-cluster
AWS_REGION=eu-west-1

function createCluster() {
	echo "Updating cluster $CLUSTER_NAME"

	# Create stack from CF template
	aws cloudformation update-stack --stack-name $STACK_NAME --parameters ParameterKey=ClusterName,ParameterValue=$CLUSTER_NAME --template-body file://bootifulmicropizza_stack.yml --region $AWS_REGION --capabilities CAPABILITY_IAM
}

createCluster $@
