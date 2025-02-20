resource "aws_security_group" "acesso_geral" {
  name        = var.grupoDeSeguranca #"acesso_geral" nao precisa mais passar diretamente o nome do grupo. Agora esta definido no arquivo de variaveis
  description = "grupo do Dev"
  ingress {
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    from_port        = 0    # como começa com 1, zero significa todas as portas
    to_port          = 0    # como começa com 1, zero significa todas as portas
    protocol         = "-1" # para liberar todos os protocolos
  }

  egress {
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    from_port        = 0    # como começa com 1, zero significa todas as portas
    to_port          = 0    # como começa com 1, zero significa todas as portas
    protocol         = "-1" # para liberar todos os protocolos    
  }

  tags = {
    Name = "acesso_geral"
  }
}
