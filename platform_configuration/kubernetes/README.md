### Kubernetes ###

This repository includes these roles

- helm
- kube
- kubecli

helm
=========

This role downloads and locates the helm binaries inside the host(s) setting an environment ready to run helm, including the apply of the external-dns info

Requirements
------------

helm requires an kubectl installed to run properly inside the host(s)

kube
=========

kube role provides and installs the resources needed to have kubectl in the objetive host for ansible.
	
kubecli
=========

The kubecli role installs python pip and uses pip installs the awscli along with the aws authenticator

Requirements
------------

In order to run this playbook, the working environment must count with the environment variables and its content listed below:
WORKSPACE = < root path of the agent >
AWS_ACCESS_KEY_ID = < aws access key >
AWS_SECRET_KEY_ID = < aws secret key >

Example Playbook 
----------------

There are three roles in this repository (kube, terra & istio), in order to use them all run the playbook within this repository. 
You can change the playbook.yml removing the unrequired roles or creating one like the example below

---
- hosts: all
  roles:
      - kube
      - kubecli
      - helm
