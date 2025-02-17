terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  profile = "default"
  region  = var.regiao_aws #"us-west-2" does not need to pass the name, but reference the variable created in the variables folder
}

resource "aws_instance" "app_server" {
  ami           = "ami-03d5c68bab01f3496"
  instance_type = var.instancia #"t2.micro" | dont need to pass the name, but reference the variable created in the variables folder
  key_name      = var.chave     #"samukapcrypto-iac-key" | dont need to pass the name, but reference the variable created in the variables folder
  /*
  user_data = <<-EOF
                 #!/bin/bash

                 exec > /tmp/user_data.log 2>&1
                 set -x

                 # Criando diretório e configurando permissões
                 sudo mkdir -p /var/www/html
                 sudo cd /var/www/html
                 sudo chmod 755 /var/www/html

                 # Criando a página HTML de teste
                 echo "<h1>Feito com Terraform para teste...</h1>" | sudo tee /var/www/html/index.html

                 # Instalando o busybox (caso não esteja instalado)
                 sudo apt update -y
                 sudo apt install -y busybox

                 # Aguardar a inicialização completa da instância antes de iniciar o servidor
                 sleep 10

                 # Verificando se o busybox foi instalado corretamente
                 which busybox

                 # Iniciando o servidor HTTP e verificando se o processo foi iniciado
                 sudo nohup busybox httpd -f -p 8080 -h /var/www/html &

                 # Verificando se o processo do servidor HTTP foi iniciado
                 ps aux | grep busybox
                 EOF
  */
  tags = {
    Name = "Samukapcrypto Terraform Ansible Python AWS"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_key_pair" "chaveSSH" {
  key_name   = var.chave                # DEV Dont need to pass the value name directly, but reference the created one.
  public_key = file("${var.chave}.pub") #file("IaC-DEV") Dont need to pass the value name directly, but reference the created one.
}
