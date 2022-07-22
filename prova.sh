#!/bin/bash

Main () {
    checarArgumentos $*
    checarDiretorio $*

    echo "Exibindo os arquivos que contém a palavra $1"
    echo "a partir do diretório $2"
    grep -so "$1" * .*
    echo
}
checarArgumentos () {
    if [ $# -ne 2 ]; then
        echo "Execute o script ./ex07.sh informando"
        echo "palavra e o diretório separado por espaço"
        echo; exit
    fi
}
checarDiretorio () {
    if [ ! -d $2 ]; then
        echo "O $2 informado não existe"
        echo "Execute o script ./ex07.sh novamente"
        echo; exit
    fi
}
Main $*
