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

resource "aws_launch_template" "maquina" {
  image_id      = "ami-03d5c68bab01f3496"
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
  security_group_names = [var.grupoDeSeguranca]
  user_data            = var.producao ? ("ansible.sh") : ""
}

resource "aws_key_pair" "chaveSSH" {
  key_name   = var.chave                # DEV Dont need to pass the value name directly, but reference the created one.
  public_key = file("${var.chave}.pub") #file("IaC-DEV") Dont need to pass the value name directly, but reference the created one.
}

#output "IP_publico" {
#value = aws_instance.app_server.public_ip
#}

resource "aws_autoscaling_group" "grupo" {
  availability_zones = ["${var.regiao_aws}a", "${var.regiao_aws}b"]
  name               = var.nomeGrupo
  max_size           = var.maximo
  min_size           = var.minimo
  launch_template {
    id      = aws_launch_template.maquina.id
    version = "$Latest"
  }
  target_group_arns = var.producao ? [aws_lb_target_group.alvoLoadBalancer.arn] : []
}

resource "aws_autoscaling_schedule" "liga" {
  scheduled_action_name  = "liga"
  min_size               = 0
  max_size               = 1
  desired_capacity       = 1
  start_time             = timeadd(timestamp(), "10m")
  autoscaling_group_name = aws_autoscaling_group.grupo.name
  recurrence             = "0 9 * * MON-FRI"
}

resource "aws_autoscaling_schedule" "desliga" {
  scheduled_action_name  = "desliga"
  min_size               = 0
  max_size               = 1
  desired_capacity       = 0
  start_time             = timeadd(timestamp(), "11m")
  autoscaling_group_name = aws_autoscaling_group.grupo.name
  recurrence             = "0 20 * * MON-FRI"
}

resource "aws_default_subnet" "subnet_1" {
  availability_zone = "${var.regiao_aws}a"
}

resource "aws_default_subnet" "subnet_2" {
  availability_zone = "${var.regiao_aws}b"
}

resource "aws_lb" "loadBalancer" {
  internal = false
  subnets  = [aws_default_subnet.subnet_1.id, aws_default_subnet.subnet_2.id]
  count    = var.producao ? 1 : 0

}

resource "aws_lb_target_group" "alvoLoadBalancer" {
  name     = "maquinasAlvo"
  port     = "8000"
  protocol = "HTTP"
  vpc_id   = aws_default_vpc.default.id
}

resource "aws_default_vpc" "default" {

}


resource "aws_lb_listener" "entradaLoadBalancer" {
  load_balancer_arn = aws_lb.loadBalancer[*].arn[0]
  port              = "8000"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alvoLoadBalancer.arn
  }
  count = var.producao ? 1 : 0
}

resource "aws_autoscaling_policy" "escala-Producao" {
  name                   = "terraform-escala"
  autoscaling_group_name = var.nomeGrupo
  policy_type            = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization" # Se o consumo de cpu for maior do que 50%, cria outra máquina
    }
    target_value = 50.0
  }
  count = var.producao ? 1 : 0 # apenas para producao

}
