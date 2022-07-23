#!/usr/bin/env bash
# Purpose: Counts the total amount of images from the AWS bucket were used on the blog posts conversion
# Author: Vinícius Godoy (vinicius-godoy)

Main () {
  checkArguments $*
  
  if [ -d $1 ] && [ -d $2 ]; then
    cd $1
    folders=`ls`
    imageTotal=`ls $2`
    imageTotal=`echo "$imageTotal" | wc -l`
    imageCount=0
    for folder in $folders; do
      images=`grep -Eo 'https:\/\/guiamake\.s3\.sa-east-1\.amazonaws\.com\/public\/.+\.(png|jpg|jpeg)' $1/$folder/index.mdx`
      
      for image in $images; do
        imageCount=$[imageCount + 1]
      done
    done
    echo "$imageCount de $imageTotal images utilizadas"
  fi
}

checkArguments (){
  if [ $# -ne 2 ]; then
    echo "O script precisa de 2 argumentos"
    echo "Primeiro o diretório onde estão as pastas de posts e depois diretório com as imagens";
    echo "Exemplo: ./script  ./novosArquivos/"
    exit
  fi
}

Main $*
