# EKS cluster creation and initial setup

This repo contains a CloudFormation template to create the EKS cluster within
AWS and setup and install various Kubernetes applications.

## Create a cluster

The `create_cluster.sh` can be used to create a new cluster with the provided name.

e.g. `./create_cluster.sh bootifulmicropizza`

Once the cluster has been created, the Dashboard token can be retrieved by executing the following command:

`kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep eks-admin | awk '{print $1}')`

The local proxy to serve the dashboard through can then be started:

`kubectl proxy`

Open the browser at http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/#!/login and enter the token when prompted.

## Ingress

The standard Kubernetes Ingress controller is installed such that it is ready for use by applications. Any application that requires exposing to the internet simply requires an ingress definition:

```
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: nginx
spec:
  rules:
    - host: www.bootifulmicropizza.com
      http:
        paths:
        - path: /
          backend:
            serviceName: nginx
            servicePort: 80
```

## Delete a cluster

The `delete_cluster.sh` script can be used to delete a cluster with the provided name.

e.g. `./delete_cluster.sh bootifulmicropizza`

### References
- https://github.com/thestacks-io/eks-cluster
- https://hackernoon.com/quickly-spin-up-an-aws-eks-kubernetes-cluster-using-cloudformation-3d59c56b292e
- https://docs.aws.amazon.com/eks/latest/userguide/dashboard-tutorial.html
- https://kubernetes.io/docs/tasks/administer-cluster/namespaces-walkthrough/
- https://www.blazemeter.com/blog/how-to-setup-scalable-jenkins-on-top-of-a-kubernetes-cluster
- https://eksworkshop.com
