vault-init
=========

Vault-init creates directories required to save vault unseal-keys and root-key, initialize the vault operator pointing to the vault address listed inside the role and saving its keys in the directories formerly created.

These are all the tasks made in this role:
* creates a directory to save the unseal keys
* create a directory to save the root key
* initialise Vault operator, making vault ready to run
* once initialized vault prints it´s keys and those are read as a yml file
* the unseal keys are saved inside the directory created for unseal keys 
* the root key is saved inside the directory created for that purpose 
 

Requirements
------------

* The port 8200 must be open to trafic for itself and the other devices/instances required to access vault and a S3 bucket

Example Playbook
----------------

    - hosts: servers
      roles:
         - vault-init