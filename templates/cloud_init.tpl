#cloud-config

users:
{% for user in users %}
  - name: {{ user.name }}
    sudo: 
      - "ALL=(ALL) NOPASSWD:ALL"
    shell: /bin/bash
    ssh-authorized-keys:
      - {{ user.public_key }}
{% endfor %}