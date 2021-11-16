helm
=========

This role downloads and locates the helm binaries inside the host(s) setting an environment ready to run helm, including the apply of the external-dns info. The tasks mentioned before are made in the next order:

 * downloads helm bin
 * unarchives helm+tiller bin
 * moves helm & tiller to a directory inside the PATH var
 * inits helm
 * creates tiller serviceaccount
 * creates role binding
 * applies files as patches first tiller and then external-dns

Requirements
------------

helm requires an kubectl installed to run properly inside the host(s)

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - helm