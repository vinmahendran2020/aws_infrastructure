Deploy-Infra
=========


This role deploys cloud infrastructure through Terraform. It can also destroy the generated infrastructure.

The role is able to plan and/or apply the infrastructure. It acts as a wrapper, and adds plan-only functionality to the official Terraform Ansible module, found [here](https://docs.ansible.com/ansible/latest/modules/terraform_module.html).


Tasks in role:

* Plan - calls the Terraform Ansible module in check mode to generate a Terraform plan
* Apply - calls the Terraform Ansible module to apply the desired infrastructure

Results
------------
- Cloud infrastructure provisioned in the cloud provider of choice

Requirements
------------

- A working set of Terraform files (`*.tf`)
- A variables file containing values of variables
- Terraform version `>=0.12.4` installed
- A set of credentials that allow Terraform to interact with the cloud provider of choice 
- OPTIONAL BUT HIGHLY RECOMMENDED - a remote Terraform backend already configured
  - If not configured, Terraform state will end up in the same location as where this role is run (if this is a CI/CD system, the state may be lost!)
  - An example Ansible playbook to provision this can be [here](https://innersource.accenture.com/projects/BLOCKOFZ/repos/fulcrum-infrastructure-backend/browse) 

Role Variables
--------------

> Note - `plan=true` can be specified as a variable if the desired functionality is to only run `terraform plan`. If `plan` is not defined, the module will run to completion i.e. `terraform apply`. It is **intentionally undefined** by default.

||||
|--- |--- |--- |
|Variable|Use|Default value|
|project_path|The path to the root of the Terraform directory with the vars.tf/main.tf/etc to use.|The current directory, i.e. `"./"`|
|state|Goal state (planned, present, absent).|"present"|
|force_init|To avoid duplicating infra, if a state file can't be found this will force a `terraform init`. Generally, this should be turned off unless you intend to provision an entirely new Terraform deployment, or if running inside CI/CD (`terraform init` will force a fetch of remote state).|"false"|
|backend|A group of key-values to provide at init stage to the `--backend-config` parameter.|`{}`|
|variables_file|The path to a variables file for Terraform to fill into the TF code. This variable file may be statically defined, or generated through Ansible templating.|`"./vars.tfvars"`|
|workspace|The terraform workspace to work with.|"default"|
|plan|If defined, and `plan=="true"`, the module will only run `terraform plan`, and stop afterwards. It is **intentionally undefined** by default.|_undefined_
||||


Example Playbook
----------------
> Note - the following values can be filled in by other playbooks/roles instead of being hardcoded. The Jinja2 templating engine would be used for this, e.g. `{{ variables_file_path }}` with `vars.variables_file_path="./vars.tfvars"` being defined at a higher level.



```yaml
- name: Deploy Terraform
  include_role:
    name: deploy-infra
  vars:
    variables_file: "./vars.tfvars"
    # aws/azure/gcp/etc.
    project_path: "./aws"
    state: "present"
    force_init: "true"
    workspace: "dev" # test / prod
    backend_config: 
      # example AWS S3 remote backend config
      bucket: "terraform-remote-state"
      key: "terraform"
      region: "eu-west-1"
      dynamodb_table: "terraform-remote-state-lock"
    # workflow - define the below if only plan is desired, otherwise leave undefined
    plan: "true"
```
