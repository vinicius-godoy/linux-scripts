#!/bin/bash
clear; echo
if [ $# -ne 2 ]; then
  echo "Forneça como argumentos do script o diretório e a extensão"; echo
  echo "Exemplo: /home/texto txt"; echo
  exit
fi
if [ -d $1 ]; then
  cd $1
  ls *.$2; echo
  arquivos=`ls *[-]*.$2`
  echo "Renomeia os arquivos"; echo
  echo "Troca - (hífen) por _ (underline)";echo
  for arq in $arquivos;do
    novoarq="${arq//-/_}"
    echo "$arq -> $novoarq"
    mv $arq $novoarq
  done
  echo;
  echo "Finalizado"; echo
else
  echo "O diretório $1 não existe"; echo
fi 
