#!/usr/bin/env bash

Main () {
checkArguments $*

menuLoop $*
}

checkArguments () {
  if [ $# -ne 1 ]; then
    echo "O script precisa de 1 argumento"
    echo "Precisa ser um arquivo";
    echo "Exemplo: comando /caminho/até/arquivo.extensão"
    exit
  fi

  if [[ ! -e $1 ]]; then
    echo "O arquivo fornecido NÃO existe!"
    exit
  fi
}

menuLoop () {
  clear
  echo
  echo "------------MENU-------------"
  echo "1. Ver todas as informações de contagem do arquivo"
  echo "2. Extrair enésima informação do arquivo"
  echo "3. Substituir alguma informação no arquivo"
  echo "4. Procurar por algo no arquivo"
  echo "5. Tranformar o arquivo em MAIÚSCULO ou minúsculo"
  echo "6. Remover linhas repetidas do arquivo"
  echo "7. Ordenar o arquivo"
  echo "8. Unir seu arquivo com outro"
  echo "0. Sair"
  echo; echo -n "Selecione sua opção -> "
  read opc
  case $opc in
    "1") executeWc $*;;
    "2") executeCut $*;;
    "3") executeSed $*;;
    "4") executeGrep $*;;
    "5") executeTr $*;;
    "6") executeUniq $*;;
    "7") executeSort $*;;
    "8") executePaste $*;;
    "0") exit;;
    *) handleDefault $*;;
  esac
}

executeWc () {
  bytes=`cat $1 | wc -c`
  chars=`cat $1 | wc -m`
  lines=`cat $1 | wc -l`
  maxLine=`cat $1 | wc -L`
  words=`cat $1 | wc -w`

  echo "Seu arquivo tem:"
  echo "$bytes bytes e $chars caracteres de comprimento"
  echo "$words palavras e $lines linhas"
  echo "Sua maior linha tem $maxLine caracteres de comprimento"

  waitMenu
  Main $*
}

executeCut () {
  echo
  read -p "Informe o número do campo que quer extrair do arquivo: " n
  result=`cut -d " " -f $n $1`

  echo "A $n informação do arquivo $1 é:"
  echo $result

  waitMenu
  Main $*
}

executeSed () {
  echo 
  read -p "Informe a informação a ser substituída: " old
  read -p "Informe a informação que irá substituir: " new

  result=`sed -e 's/"$old"/"$new"/' $1`

  echo
  echo "O seu arquivo modificado ficou:"
  echo $result

  waitMenu
  Main $*
}

executeGrep () {
  read -p "Digite o que você quer buscar no arquivo: " search

  result=`grep $search $1`
  result2=`grep -c $search $1`
  echo
  
  echo "Seu texto aparece em $result2 linhas, elas são:"
  echo $result

  waitMenu
  Main $*
}

executeTr () {
  echo "Transformar em maiúsculo (1) ou minúsculo (2)?"
  read -p "Opção -> " opc

  case $opc in
    1) result=`tr [:lower:] [:upper:] < $1`;;
    2) result=`tr [:upper:] [:lower:] < $1`;;
    *) ;;
  esac

  echo
  echo "Seu texto após a transformação:"
  echo $result

  waitMenu
  Main $*
}

executeUniq () {
  echo
  result=`uniq $1`

  echo "Seu texto apenas com linhas únicas:"
  echo result

  waitMenu
  Main $*
}

executeSort () {
  echo "Ordenar alfabeticamente (1), ao contrário (2) ou aleatóriamente (3)?"
  read -p "Opção -> " opc

  case $opc in
    1) result=`sort $1`;;
    2) result=`sort -r $1`;;
    3) result=`sort -R $1`;;
    *) ;;
  esac

  echo
  echo "Seu texto ordenado:"
  echo $result

  waitMenu
  Main $*
}

executePaste () {
  read -p "Dê o caminho do arquivo que você irá unir: " file

  if [ -e $file ]; then
    result=`paste $1 $file`
    echo "Seus arquivos unidos:"
    echo $result
  else
    echo "Esse arquivo não existe!!!"
  fi

  waitMenu
  Main $*
}

handleDefault () {
  clear
  echo "Escolha uma opção existente!!!"
  
  sleep 2
  Main $*
}

waitMenu () {
  echo
  echo -n "Voltando ao menu em"
  echo -n " 5,"
  sleep 1
  echo -n " 4,"
  sleep 1
  echo -n " 3,"
  sleep 1
  echo -n " 2,"
  sleep 1
  echo -n " 1..."
  sleep 1
}

Main $*
