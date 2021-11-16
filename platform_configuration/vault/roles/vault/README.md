vault
=========

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
 

Requirements
------------

* The port 8200 must be open to trafic for itself and the other devices/instances required to access vault and a S3 bucket

Role Variables
--------------

- VAULT_BUCKET = < name of the bucket made for vault >
- AWS_ACCESS_KEY_ID = < aws access key >
- AWS_SECRET_KEY_ID = < aws secret key >

Example Playbook
----------------

    - hosts: servers
      roles:
         - vault