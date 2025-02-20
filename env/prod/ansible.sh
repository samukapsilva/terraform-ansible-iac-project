#!/bin/bash
cd /home/ubuntu
curl “https://bootstrap.pypa.io/get-pip.py -o get-pip.py
sudo python3 get-pip.py
sudo python3 -m pip install ansible
tee -a playbook.yml > /dev/null <<EOT
- hosts: localhost
  tasks:
    - name: Instalando o python3 e o virtualenv
      apt:
        pkg:
          - python3
          - virtualenv
        update_cache: yes
      become: yes

    - name: Git Clone
      ansible.builtin.git:
        repo: https://github.com/samukapsilva/clientes-smk-api.git
        dest: /home/ubuntu/paap
        version: master
        force: yes

    - name: Instalando dependências com pip (Django e Django Rest)
      pip:
        virtualenv: /home/ubuntu/paap/venv
        requirements: /home/ubuntu/paap/requirements.txt
           
      ignore_errors: yes

    - name: Alterando os hosts do settings
      lineinfile:  
        path: /home/ubuntu/paap/setup/settings.py
        regex: 'ALLOWED_HOSTS'
        line: 'ALLOWED_HOSTS = ["*"]'
        backrefs: yes
    
    - name: configurando o banco de dados
      shell: '. /home/ubuntu/paap/venv/bin/activate; python /home/ubuntu/paap/manage.py migrate'

    - name: carregando os dados iniciais
      shell: '. /home/ubuntu/paap/venv/bin/activate; python /home/ubuntu/paap/manage.py loaddata clientes.json'

    - name: Iniciando o Servidor
      shell: '. /home/ubuntu/paap/venv/bin/activate; nohup python /home/ubuntu/papp/manage.py runserver 0.0.0.0:8000 &'
EOT

ansible-playbook playbook.yml 
