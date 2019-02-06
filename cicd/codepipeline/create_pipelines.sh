#!/bin/bash

echo "Creating Code Pipelines..."

#aws cloudformation create-stack --stack-name ecr --template-body file://iac/ecr.yml --region eu-west-1

ACCOUNT_ID=`aws sts get-caller-identity --output text --query 'Account'`
JAVA_IMAGE=$ACCOUNT_ID.dkr.ecr.eu-west-1.amazonaws.com/codebuild_image
NODE_IMAGE=aws/codebuild/nodejs:10.14.1

aws cloudformation create-stack --stack-name config-service-codepipeline \
    --template-body file://iac/codepipeline.yml --region eu-west-1 \
    --parameters ParameterKey=BuildImageName,ParameterValue=$JAVA_IMAGE ParameterKey=ModuleName,ParameterValue=config-service ParameterKey=GitHubToken,ParameterValue=$AWS_GITHUB_TOKEN \
    --capabilities CAPABILITY_NAMED_IAM

aws cloudformation create-stack --stack-name registry-service-codepipeline \
    --template-body file://iac/codepipeline.yml --region eu-west-1 \
    --parameters ParameterKey=BuildImageName,ParameterValue=$JAVA_IMAGE ParameterKey=ModuleName,ParameterValue=registry-service ParameterKey=GitHubToken,ParameterValue=$AWS_GITHUB_TOKEN \
    --capabilities CAPABILITY_NAMED_IAM

aws cloudformation create-stack --stack-name inventory-service-codepipeline \
    --template-body file://iac/codepipeline.yml --region eu-west-1 \
    --parameters ParameterKey=BuildImageName,ParameterValue=$JAVA_IMAGE ParameterKey=ModuleName,ParameterValue=inventory-service ParameterKey=GitHubToken,ParameterValue=$AWS_GITHUB_TOKEN \
    --capabilities CAPABILITY_NAMED_IAM

aws cloudformation create-stack --stack-name website-gateway-codepipeline \
    --template-body file://iac/codepipeline.yml --region eu-west-1 \
    --parameters ParameterKey=BuildImageName,ParameterValue=$JAVA_IMAGE ParameterKey=ModuleName,ParameterValue=website-gateway ParameterKey=GitHubToken,ParameterValue=$AWS_GITHUB_TOKEN \
    --capabilities CAPABILITY_NAMED_IAM

aws cloudformation create-stack --stack-name website-app-codepipeline \
    --template-body file://iac/codepipeline.yml --region eu-west-1 \
    --parameters ParameterKey=BuildImageName,ParameterValue=$NODE_IMAGE ParameterKey=ModuleName,ParameterValue=website ParameterKey=GitHubToken,ParameterValue=$AWS_GITHUB_TOKEN \
    --capabilities CAPABILITY_NAMED_IAM
