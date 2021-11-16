# Nonprod provisioning

## Ansible roles

In ansible, roles provide a framework for fully independent, or interdependent collections of variables, tasks, files, templates, and modules.

Each role is basically limited to a particular functionality or desired output, with all the necessary steps to provide that result.

## Requirements to run an ansible role

Roles are small functionality which can be independently used but have to be used within playbooks. There is no way to directly execute a role, if you need to run an ansible role is required to use a playbook listing that role inside, like the following example:

```
--- 
- hosts:< name of the host group >
roles: 
   - {role: first role} 
   - {role: second role}
```

```
--- 
- hosts: all
roles: 
   - infra
   - kubernetes
```
This directory contains ansible roles implemented in the deployment of nonprod environment:

* destroy-terra
* infra
* kubernetes
* vault

below is a brief description of what does every role do along with their requirements to run properly, if a bigger description is required check the readme file inside each role:

## destroy-terra

### Requirements

In order to run this playbook, the working environment must count with the following elements:
- two S3 bucket previously created (one for vault and other for the bastion)
- terraform software version 0.11.14 installed
- main.tf file created inside environments/nonprod/ directory
- a “terraform apply” command previously executed over that main.tf file

The environment variables and its content are listed below:
- PROJECT_NAME = < name of the proyect >
- AMI = < name of the ami >
- VAULT_BUCKET = < name of the bucket made for vault >
- VAULT_PUBLIC_KEY = < ssh public key of the vault instance >
- BASTION_BUCKET = < name of the bucket made for the bastion >
- BASTION_PUBLIC_KEY = < ssh public key of the bastion instance >
 
### Description

This role calls all hosts of the ansible agent as super-user performing 3 terraform tasks to destroy the environment listed inside the terraform/environments/nonprod/ directory

 ## infra

### Requirements

In order to run this playbook, the working environment must count with the following elements:
two S3 bucket previously created (one for vault and other for the bastion)
terraform software version 0.11.14 installed
main.tf file created inside environments/nonprod/ directory
a “terraform apply” command previously executed over that main.tf file
the environment variables and its content listed below:
- PROJECT_NAME = < name of the proyect >
- AMI = < name of the ami >
- VAULT_BUCKET = < name of the bucket made for vault >
- BASTION_BUCKET = < name of the bucket made for the bastion >
- SSH_KEYS_PATH = < path to the ssh-key file >
- VAULT_PUBLIC_KEY = < ssh public key >

### Description
The infra role checks the existence of the terraform software and version inside the agent where is currently running and if that agent doesn´t count with terraform the playbook downloads it, decompress it and then makes it ready for execution.

 Once terraform is ready, the role initializes, validates, plans and applies the terraform file contained inside nonprod directory.

 ## kubernetes

### Requirements

In order to run this playbook, the working environment must count with the environment variables and its content listed below:
WORKSPACE = < root path of the agent >

 ### Description

The kubernetes role is in charge of download and provisioning kubectl, pip, awscli and aws authenticator.
The full content of this role is divided in three more roles

 - kube
 - kubecli
 - helm

All of the above are going to be used with an EKS service

 ## vault

### Requirements

In order to run this playbook, the working environment must count with the content listed below:
* The port 8200 must be open to trafic for itself and the other devices/instances required to access vault 

### Description
The vault role contains another 4 roles inside and  also is in charge to deploy hashicorp vault in three steps:

 - vault
   vault creates a user and usergroup for vault, installs prerequisites (like unarchive) downloads the hashicorp binary, unzips it and ends starting the vault service.

 - vault-init
   Vault-init creates directories required to save vault unseal-keys and root-key, initialize the vault operator pointing to the vault address listed inside the role and saving its keys in the directories formerly created.

 - vault-unseal
   vault-unseal reads and uses vault keys in order to unseal the vault with the keys saved before.
