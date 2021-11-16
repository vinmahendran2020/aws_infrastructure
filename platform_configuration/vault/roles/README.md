vault
=========

The vault role contains another 4 roles inside and  also is in charge to deploy hashicorp vault in three steps:

- vault
- vault-init
- vault-unseal

  - vault
   vault creates a user and usergroup for vault, installs prerequisites (like unarchive) downloads the hashicorp binary, unzips it and ends starting the vault service.
These are all the tasks made in this role:
 * creates an usergroup
 * creates vault user
 *  installs unzip if the instance doesn´t have it yet
 * downloads vault binaries
 * unzips vault archive
 * sets vault binarie capabilities
 * copies init file from templates directory, to a place inside the ansible host(s)
 * copies config file from templates directory to a place inside the ansible host(s)
 * initializes the vault service (note: even if the service is initilized, vault isn´t ready to be used)
 

 - vault-init
   Vault-init creates directories required to save vault unseal-keys and root-key, initialize the vault operator pointing to the vault address listed inside the role and saving its keys in the directories formerly created.
These are all the tasks made in this role:
* creates a directory to save the unseal keys
* create a directory to save the root key
* initialise Vault operator, making vault ready to run
* once initialized vault prints it´s keys and those are read as a yml file
* the unseal keys are saved inside the directory created for unseal keys 
* the root key is saved inside the directory created for that purpose 


 - vault-unseal
   vault-unseal reads and uses vault keys in order to unseal the vault with the keys saved before.

Requirements
------------

In order to run this playbook, the working environment must count with 
the content listed below:
* The port 8200 must be open to trafic for itself and the other devices/instances required to access vault 

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - vault
         - vault-init
         - vault-unseal
