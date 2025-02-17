resource "aws_security_group" "acesso_geral" {
  name        = "acesso_geral"
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
