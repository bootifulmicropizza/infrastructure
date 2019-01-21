# CI/CD CloudFormation templates

CI/CD pipeline using CodePipeline.

### Requirements

- Push code to GitHub
- Build produces new Docker image and publishes to ECR (tagged with commit hash)
- Docker image is deployed to dev environment (K8S namespace on same cluster)
- Optional next step is to deploy image to next environment. e.g. stage, or production
- As last step for next environment as required


# TODO

Currently the pipeline is using a Docker image for the codebuild part. Need to compare the performance of this compared with AWS provided images which necessary commands in module's buildspec.yml file.


#### References
https://stelligent.com/2016/01/08/provisioning-custom-codepipeline-actions-in-cloudformation/
https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-env-vars.html
https://medium.com/@BranLiang/step-by-step-to-setup-continues-deployment-kubernetes-on-aws-with-eks-code-pipeline-and-lambda-61136c84bbcd
https://github.com/kubernetes-sigs/aws-iam-authenticator/issues/157#issuecomment-442303386
