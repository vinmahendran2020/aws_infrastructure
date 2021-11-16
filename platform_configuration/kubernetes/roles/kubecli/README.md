 kubecli
====================

Installs python pip, awscli and aws authenticator inside the host(s).

The kubecli tasks are made in the following order:

  * pip (used to install awscli)
    
  * Install awscli 
  * Gives aws access key
  * Gives aws secret access key
  * Gives aws region
  * Downloads aws cli authenticator
  * changes aws authenticator permissions
  * moves aws authenticator to a directory already in the PATH var

Example Playbook
----------------

```
- hosts: your-host
  roles:
    - kubecli
```
 
