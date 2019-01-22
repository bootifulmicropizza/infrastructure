# Code Build Docker Image

To speed up the build process, a custom Docker image is required that contains everything we need.

The Dockerfile is a copy of the official image at https://github.com/aws/aws-codebuild-docker-images/blob/master/ubuntu/docker/18.09.0/Dockerfile with a few modifications to include `openjdk-8-jdk` and `maven` installation via `apt-get`.

The Docker image is hosted in a private AWS ECR repository and referenced in the `AWS::CodeBuild::Project` CloudFormation template:

```
Image: !Sub ${AWS::AccountId}.dkr.ecr.eu-west-1.amazonaws.com/codebuild_image
```
