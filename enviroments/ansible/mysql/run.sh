pip install ansible
ansible-galaxy install robertdebock.mysql
ansible-playbook -i localhost --limit localhost deploy_mysql.yaml --ask-become-pass