#!/usr/bin/env bash

Principal () {
  clear; echo
  echo "           MENU           "
  echo "--------------------------"
  echo "1. Identificar um Usuário"
  echo "2. Criar um Usuário"
  echo "3. Apagar um Usuário"
  echo "4. Sair"
  echo; read -p "Escolha uma opção: " op; echo
  case $op in
    1) identifica;;
    2) cria;;
    3) apaga;;
    4) sair;;
    *) erro;;
  esac
}

senha () {
  clear; echo;
  read -sp "Digite a senha para continuar: " senha; echo
  if [ $senha = "senhaboa" ]; then
    Principal
  else
    read -p "A senha digitada está errada. Pressione ENTER para tentar novamente: " op; echo
    senha
  fi
}

identifica () {
  clear; echo
  read -p "Digite o nome do usuário: " usuario; echo
  if id -u "$usuario" > /dev/null 2>&1; then
    id $usuario
  else
    echo "Usuário não existe!"
  fi
  volta
}

cria () {
  clear; echo
  read -p "Digite o nome do usuário que deseja criar: " usuario; echo
  if id -u "$usuario" > /dev/null 2>&1; then
    echo "O usuário $usuario já existe!"
  else
    sudo useradd -m $usuario
    sudo passwd $usuario
  fi
  volta
}

apaga () {
  clear; echo
  read -p "Digite o nome do usuário que deseja deletar: " usuario; echo
  if id -u "$usuario" > /dev/null 2>&1; then
    echo "Deletando o usuário $usuario. Por favor aguarde!"
    sudo userdel -r $usuario
    sudo rm -rf /home/$usuario
  else
    echo "O usuário $usuario NÃO existe!"
  fi
  volta
}

sair () {
  echo "Encerrando..."; sleep 5; clear; exit
}

erro () {
  clear; echo "Digite uma opção válida! (1-4)"; volta
}

volta () {
  sleep 3; Principal
}

senha
