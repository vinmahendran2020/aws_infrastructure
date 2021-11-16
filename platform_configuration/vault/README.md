vault
=========

The vault role contains another 4 roles inside and  also is in charge to deploy hashicorp vault in three steps:

- vault
- vault-init
- vault-unseal

  - vault
   vault creates a user and usergroup for vault, installs prerequisites (like unarchive) downloads the hashicorp binary, unzips it and ends starting the vault service.

 - vault-init
   Vault-init creates directories required to save vault unseal-keys and root-key, initialize the vault operator pointing to the vault address listed inside the role and saving its keys in the directories formerly created.

 - vault-unseal
   vault-unseal reads and uses vault keys in order to unseal the vault with the keys saved before.

Requirements
------------

* The port 8200 must be open to trafic for itself and the other devices/instances required to access vault 

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - vault
         - vault-init
         - vault-unseal