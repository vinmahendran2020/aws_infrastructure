vault-unseal
=========

vault-unseal reads and uses vault keys in order to unseal the vault with the keys saved before.


Requirements
------------

* The roles vault and vault-init must be run before this role
The instance must have the unseal keys and root key in the path listed inside the role.
* The port 8200 must be open to trafic for itself and the other devices/instances required to access vault and a S3 bucket

Example Playbook
----------------

    - hosts: servers
      roles:
         - vault-unseal