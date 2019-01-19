# CI/CD CloudFormation templates

Options for CI/CD pipeline; Jenkins or CodeBuild.

## Jenkins

See the Jenkins directory.

## CodeBuild

`aws cloudformation create-stack --stack-name build-deploy-config-service-cf --template-body file://codebuild/codebuild.yml --region eu-west-1 --parameters ParameterKey=ModuleName,ParameterValue=config-service ParameterKey=GitHubToken,ParameterValue=$AWS_GITHUB_TOKEN --capabilities CAPABILITY_NAMED_IAM`

### Requirements

- Push code to GitHub
- Build produces new Docker image and publishes to ECR (tagged with commit hash)
- Docker image is deployed to dev environment (K8S namespace on same cluster)
- Optional next step is to deploy image to next environment. e.g. stage, or production
- As last step for next environment as required

#### References
https://stelligent.com/2016/01/08/provisioning-custom-codepipeline-actions-in-cloudformation/
