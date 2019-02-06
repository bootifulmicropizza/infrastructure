# DEVOPS

This repo contains CF templates/K8S configuration to create the tools necessary
for operational monitoring. This includes, monitoring via Grafana and logging
via ELK stack.


Running the CF template for the elk stack requires the service linked role for ES:

`$ aws iam create-service-linked-role --aws-service-name elasticsearch.amazonaws.com`

