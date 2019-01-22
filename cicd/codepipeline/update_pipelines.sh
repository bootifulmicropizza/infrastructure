#!/bin/bash

echo "Updating Code Pipelines..."

aws cloudformation update-stack --stack-name config-service-codepipeline --template-body file://iac/codepipeline.yml --region eu-west-1 --parameters ParameterKey=ModuleName,ParameterValue=config-service ParameterKey=GitHubToken,ParameterValue=$AWS_GITHUB_TOKEN --capabilities CAPABILITY_NAMED_IAM

aws cloudformation update-stack --stack-name registry-service-codepipeline --template-body file://iac/codepipeline.yml --region eu-west-1 --parameters ParameterKey=ModuleName,ParameterValue=registry-service ParameterKey=GitHubToken,ParameterValue=$AWS_GITHUB_TOKEN --capabilities CAPABILITY_NAMED_IAM
