destroy-terra
=========

This role calls all hosts of the ansible agent as super-user performing 3 terraform tasks to destroy the environment listed inside the terraform/environments/nonprod/ directory
* terraform init
  - initialize a working directory containing Terraform configuration files
* terraform state pull
  - This command will download the state from its current location and output the raw format to stdout.
* terraform destroy
   - This command is used to destroy the Terraform-managed infrastructure.

Requirements
------------

- Proyect
- Ami
- bucket for vault
- bucket for bastion
- ssh public key of the instance

Role Variables
--------------

- PROJECT_NAME = < name of the proyect>
- AMI = < name of the ami>
- VAULT_BUCKET = < name of the bucket made for vault>
- BASTION_BUCKET = < name of the bucket made for the bastion>

Example Playbook
----------------

    - hosts: servers
      roles:
         - destroy-terra
