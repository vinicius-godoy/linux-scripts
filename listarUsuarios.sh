#!/bin/bash
clear; echo
echo "Lendo o /etc/passwd e exibindo os usuários com id maior ou igual a 500"
while IFS=: read -r nome senha identificacao grupo comentario diretorio shell; do
  if [ $identificacao -ge "500" ]; then
    echo
    echo "Usuário...........................: $nome"
    echo "Com Identificação.................: $identificacao"
    echo "Identificação do grupo............: $grupo"
    echo "Comentário........................: $comentario"
    echo "Diretório Nativo..................: $diretorio"
    echo "Shell.............................: $shell"
    sleep 6
  fi
done < /etc/passwd
echo
