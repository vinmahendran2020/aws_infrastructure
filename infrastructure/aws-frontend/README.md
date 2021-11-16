# Ion Frontend Terraform Modules

## Pre-Requisites:

- ion-infrastructure backend module should be created first by adding the backend configuration to the orgs list first in the **../../network.yaml**
    - this is needed to create the public **Route53 Hosted Zone** for the specified environment

## Post-Requisites:

- Manual creation of a **Route53 Alias record** in the public **Route53 Hosted Zone** pointing to the ALB DNS name created by K8s Ingress.
    - this is used to access the frontend application with a user-friendly DNS name and HTTPS support

## How it works:

- Ansible creates **generated-vars.tfvars** using **../../network.yaml** and **../../templates/terraform_tfvars_aws-frontend.tpl** with Ansible playbooks in the root of the ion-infrastructure project
    - The Ansible commands from root of project:
        - terraform plan: `ansible-playbook site.yml -vv --inventory-file=inventory/ --extra-vars "@./network_frontend.yml" --extra-vars "plan=true"`
        - terraform apply: `ansible-playbook site.yml -vv --inventory-file=inventory/ --extra-vars "@./network_frontend.yml"`
        - terraform destroy: `ansible-playbook site.yml -vv --inventory-file=inventory/ --extra-vars "@./network_frontend.yml" --extra-vars "state=absent"`

- ./main.tf = root terraform module
    - declares terraform version
    - declares providers
    - declares child modules
    - feeds in variables to child modules using **generated-vars.tfvars**
        
- ./modules = self-contained child terraform modules

### Module Resources:

| Module | Description | Resources |
| ----------- | ----------- | ----------- |
| vpc | Ion frontend base AWS infrastructure | VPC, Nat Gtwys, IGs, private/public subnets, VPC Endpoints, etc.
| eks | Ion frontend Kubernetes cluster hosted in AWS EKS | EKS, Worker Group EC2 instances, SGs
| ecr | Frontend AWS ECR repos for storing container images used by Kubernetes pods | ECR Repos
| cognito | User authentication and authorization using AWS Cognito | User pool, User groups, Identity pool 
| dns | DNS SSL certificates and validation using AWS ACM and Route53 | ACM Certificate, Route53 certificate validation CNAME record
| waf | AWS WAF used to prevent malicious requests to the frontend ALB | WAF Web ACL with managed rule groups based on OWASP top 10
| k8s | Kubernetes resources used by the Ion frontend EKS cluster | k8s namespace, cloudwatch support for pods, ingress with ALB controller & path-based routing
