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

  kubectl delete -f nginx/
  kubectl delete -f ingress/

	# Delete stack from CF
	aws cloudformation delete-stack --stack-name $STACK_NAME --region $AWS_REGION
}

deleteCluster $@
