#!/usr/bin/env bash
# Purpose: Convert blog posts and its front matters from a specific older layout to a newer layout of the blog
# Author: Vinícius Godoy (@vinicius-godoy)

Main () {
  checkArguments $*

  if [ -d $1 ] && [ -d $2 ]; then
    cd $1
    files=`ls *.md`
    fileCount=1
    fileTotal=`echo "$files" | wc -w` # Gets the total number of files on the to be updated directory
    for file in $files; do
      count=0
      title=""
      description=""
      # Categories and tags need to begin with empty space for normalization purposes later on the program
      categories=" "
      tags=" "
      while IFS=: read -r key value; do
        if [ "$key" = "---" ]; then
          count=$[count + 1]
        fi
        case $key in
          "date") dateVar=$value;;
          "draft") draft=$value;;
          "title") slug=$value;;
          "h1SEO") lastValue="title"; title=$value;;
          "descriptionSEO") descriptionNullCheck;;
          "author") author=$value;;
          "image") thumbnail=$value;;
          "description") descriptionNullCheck;;
          "tags") lastValue="tags";;
          "category") lastValue="category";;
          # Some key values never used on the new template
          "format") ;;
          "seo") ;;
          "cover") ;;
          "images") ;;
          *) multiLineValues;;
        esac
        if [ $count -eq 2 ]; then
          # After reaching the end of the frontmatter stop reading the file
          break
        fi
      done < $file
      normalizeStrings
      createNewFiles $*
      porcent=`bc <<< "scale=2; ($fileCount/$fileTotal)*100"`
      porcent=${porcent/.00}
      echo "Arquivo $fileCount/$fileTotal criado com sucesso! $porcent% concluído"
      fileCount=$[fileCount + 1]
    done
  fi
}

checkArguments (){
  if [ $# -ne 2 ]; then
    echo "O script precisa de 2 argumentos"
    echo "Primeiro o diretório onde estão os frontmatters antigos e depois o novo diretório";
    echo "Exemplo: ./script  ./novosArquivos/"
    exit
  fi
}

descriptionNullCheck (){
  lastValue="description"
  if [ "$value" != "''" ] & [ "$value" != "" ]; then
    description=$value
  fi
}

multiLineValues (){
  if [ "$key" = "---" ] || [[ ! -z $value ]]; then
    lastValue=""
    return
  fi
  case $lastValue in
    "tags") tags="${tags}.'${key/- }'";;
    "description") description="${description}${key}";;
    "category") categories="${categories}.'${key/- }'";;
    "title") title="${title}${key}";;
    *) ;;
  esac
}

# Remove dupe spaces and transform tags and categories on javascript style arrays
normalizeStrings () {
  description=${description//  / }
  title=${title//  / }
  tags=${tags//".''"}
  tags=${tags/ ./[}
  tags=${tags//./, }
  tags="${tags}]"
  categories=${categories//".''"}
  categories=${categories/ ./[}
  categories=${categories//./, }
  categories="${categories}]"
}

createNewFiles () {
  folder=${file//.md}
  mkdir "$2/$folder"
  touch "$2/$folder/index.mdx"
  echo "---" >> "$2/$folder/index.mdx"
  echo "title:$title" >> "$2/$folder/index.mdx"
  echo "slug:$slug" >> "$2/$folder/index.mdx"
  echo "date:$dateVar" >> "$2/$folder/index.mdx"
  echo "draft:$draft" >> "$2/$folder/index.mdx"
  echo "description:$description" >> "$2/$folder/index.mdx"
  echo "author:$author" >> "$2/$folder/index.mdx"
  echo "category: $categories" >> "$2/$folder/index.mdx"
  echo "tags: $tags" >> "$2/$folder/index.mdx"
  echo "thumbnail:$thumbnail" >> "$2/$folder/index.mdx"
  echo "---" >> "$2/$folder/index.mdx"
  echo "" >> "$2/$folder/index.mdx"
  count=0
  # -n $line reads the last line of a file with no newline at the end of it
  # better description of the problem: https://stackoverflow.com/questions/12916352/shell-script-read-missing-last-line
  while IFS=: read -r line || [ -n "$line" ]; do
    if [ $count -ge 2 ]; then
      echo "$line" >> "$2/$folder/index.mdx"
    fi
    if [ "$line" = "---" ]; then
      count=$[count + 1]
    fi
  done < $file
}

Main $*
