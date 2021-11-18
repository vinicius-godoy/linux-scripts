#!/bin/bash
Principal () {
clear; echo
read -p "Caminho do diretório: " dir; echo 
if [ -d $dir ]; then
  read -p "Digite o nome do arquivo: " arq; echo
  if [ -e "${dir}/${arq}" ]; then
    ext=`echo ${arq#*.}`
    if [ $ext = "txt" ]; then
      modificarTexto
    else
      echo "Esse arquivo não tem a extensão txt!"; echo
      reiniciar
    fi
  else
    echo "Esse arquivo não existe!"; echo
    reiniciar
  fi
else
  echo "Esse diretório não existe!"; echo
  reiniciar
fi
}
reiniciar () {
sleep 3; Principal
}
modificarTexto () {
cat "${dir}/${arq}"; echo
echo "Colocando um X na frente e atrás de todas as palavras..."; echo
for word in $(cat "${dir}/${arq}"); do
  echo -n "X${word}X "
done
echo; reiniciar
}
Principal
