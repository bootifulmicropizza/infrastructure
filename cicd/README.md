# CI/CD CloudFormation templates

Options for CI/CD pipeline; Jenkins or CodeBuild.

## Jenkins

See the Jenkins directory.

## CodeBuild

`aws cloudformation create-stack --stack-name build-deploy-config-service-cf --template-body file://codebuild/codebuild.yml --region eu-west-1 --parameters ParameterKey=ModuleName,ParameterValue=config-service --capabilities CAPABILITY_NAMED_IAM`

### Requirements

- Setup CodeBuild to build each of the bootifulmicropizza components
- Setup CodeDeploy/Code Pipeline to deploy to EKS K8S instance

### Release process

- master contains the current production code - can NEVER be a snapshot version
- development branch is where dev code lives
- release branches should be created from development branch:
	- $ mvn versions:set -DnewVersion=1.0.0
- once release branch has been built and tested it can be merged to master

AWS CodeBuild/DeployPipeline can be used to take master and deploy it to production. The pipeline could be setup such that the first environment is dev or qa before production.

#### References
https://dzone.com/articles/why-i-never-use-maven-release
