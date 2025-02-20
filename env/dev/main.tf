module "aws-dev" {
  source           = "../../infra"
  instancia        = "t2.micro"
  regiao_aws       = "us-west-2"
  chave            = "IaC-DEV"
  grupoDeSeguranca = "Dev"
  minimo           = 0
  maximo           = 1
  nomeGrupo        = "Dev"
  producao         = false
}

#output "IP" {
# value = module.aws-dev.IP_publico
#}
