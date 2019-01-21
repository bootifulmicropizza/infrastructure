#!/bin/bash

echo "Creating Code Pipelines..."

#aws cloudformation create-stack --stack-name ecr --template-body file://iac/ecr.yml --region eu-west-1

aws cloudformation create-stack --stack-name config-service-codepipeline --template-body file://iac/codepipeline.yml --region eu-west-1 --parameters ParameterKey=ModuleName,ParameterValue=config-service ParameterKey=GitHubToken,ParameterValue=$AWS_GITHUB_TOKEN --capabilities CAPABILITY_NAMED_IAM

aws cloudformation create-stack --stack-name registry-service-codepipeline --template-body file://iac/codepipeline.yml --region eu-west-1 --parameters ParameterKey=ModuleName,ParameterValue=registry-service ParameterKey=GitHubToken,ParameterValue=$AWS_GITHUB_TOKEN --capabilities CAPABILITY_NAMED_IAM
