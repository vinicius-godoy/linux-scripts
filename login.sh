#!/bin/bash
clear;echo
echo -e "Identificação do usuário XUBUNTU";
echo -e "Informe seu nome em até 10 segundos";echo
read -p "Usuário: " -t 10 usuario;echo
read -sp "Senha: " senha;echo;echo
read -sp "Código de segurança: " -n 5 codigo;echo;echo
echo -e "---------------\nCONFIRMAÇÃO DOS DADOS"
echo -e "Nome: $usuario\nSenha: $senha\nCód. Seg.: $codigo"
echo -e "---------------";echo
