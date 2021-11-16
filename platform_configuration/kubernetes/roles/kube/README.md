kube
====================

Installs kubectl command line utility used to interact with the Kubernetes API Server.

The kube tasks are made in the following order:

   * Download kubernetes-client archive
   * Unarchive kubernetes-client
   * Copy kubectl binary to destination directory

Example Playbook
----------------

```
- hosts: your-host
  roles:
    - kube
```