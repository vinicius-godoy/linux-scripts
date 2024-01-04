#!/usr/bin/env bash
# Purpose: Convert blog posts and its front matters from a specific older layout to a newer layout of the blog
# Author: Vinícius Godoy (vinicius-godoy)

Main () {
  useFlags $*
  checkArguments $*
  setGlobalParams $*

  cd $oldFrontMatters
  files=`ls *.md`
  fileCount=1
  fileTotal=`echo "$files" | wc -w | xargs` # Gets the total number of files on the to be updated directory and trim the whitespaces
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
    if [ "$isVerbose" = true ]; then
      porcent=`bc <<< "scale=2; ($fileCount/$fileTotal)*100"`
      porcent=${porcent/.00}
      echo -ne "Arquivo $fileCount/$fileTotal criado com sucesso! $porcent% concluído\r"
      fileCount=$[fileCount + 1]
    fi
  done
  if [ "$isDebug" = true ]; then
    rm -rf $newFrontMatters/*
  fi
  echo
}

Help() {
  echo "Convert all the md files from a folder from a specific frontmatter to a new layout and place them on another folder."
  echo
  echo "Syntax: $0 [-d] [-h] [-v] path/to/the/old-files ./new-files"
  echo "options:"
  echo "d     Debug mode."
  echo "h     Print this help."
  echo "v     Verbose mode."
  echo
}

useFlags () {
  options=0
  while getopts ':dhv' OPTION; do
    options=1
    case "$OPTION" in
      d) isDebug=true ;;
      h)
        Help
        exit
        ;;
      v) isVerbose=true ;;
      \?)
        echo "invalid option -$OPTARG" >&2
        echo "script usage: $0 [-d] [-h] [-v]" >&2
        exit 1
        ;;
    esac
  done
  shift "$(($OPTIND -1))"
}

checkArguments () {
  argumentsNum=$[2 + options]
  firstArg=$[$# - 1]
  secondArg=$[$#]

  if [ $# -lt $argumentsNum ]; then
    echo "The script needs 2 arguments"
    echo "First the directory where the old frontmatters files are located and second the new empty directory where the new frontmatters will be placed.";
    echo "Eg: $0 path/to/the/old-files ./new-files"
    exit 1
  fi

  if [ ! -d ${!firstArg} ]; then
    echo "The first directory provided '${!firstArg}' doesn't exist." >&2
    echo "Run the script again with a valid directory!" >&2
    echo
    exit 1
  fi

  if [ ! -d ${!secondArg} ]; then
    echo "The first directory provided '${!secondArg}' doesn't exist." >&2
    echo "Run the script again with a valid directory!" >&2
    echo
    exit 1
  fi
}

setGlobalParams () {
  initialPwd=`pwd`
  cd "${!firstArg}"
  oldFrontMatters=`pwd`
  cd "$initialPwd"
  cd "${!secondArg}"
  newFrontMatters=`pwd`
}

descriptionNullCheck () {
  lastValue="description"
  if [ "$value" != "''" ] & [ "$value" != "" ]; then
    description=$value
  fi
}

multiLineValues () {
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
  mkdir "$newFrontMatters/$folder"
  touch "$newFrontMatters/$folder/index.mdx"
  echo "---" >> "$newFrontMatters/$folder/index.mdx"
  echo "title:$title" >> "$newFrontMatters/$folder/index.mdx"
  echo "slug:$slug" >> "$newFrontMatters/$folder/index.mdx"
  echo "date:$dateVar" >> "$newFrontMatters/$folder/index.mdx"
  echo "draft:$draft" >> "$newFrontMatters/$folder/index.mdx"
  echo "description:$description" >> "$newFrontMatters/$folder/index.mdx"
  echo "perfil:$author" >> "$newFrontMatters/$folder/index.mdx"
  echo "categoria: $categories" >> "$newFrontMatters/$folder/index.mdx"
  echo "tags: $tags" >> "$newFrontMatters/$folder/index.mdx"
  echo "thumbnail:$thumbnail" >> "$newFrontMatters/$folder/index.mdx"
  echo "---" >> "$newFrontMatters/$folder/index.mdx"
  echo "" >> "$newFrontMatters/$folder/index.mdx"
  count=0
  # -n $line reads the last line of a file with no newline at the end of it
  # better description of the problem: https://stackoverflow.com/questions/12916352/shell-script-read-missing-last-line
  while IFS=: read -r line || [ -n "$line" ]; do
    if [ $count -ge 2 ]; then
      echo "$line" >> "$newFrontMatters/$folder/index.mdx"
    fi
    if [ "$line" = "---" ]; then
      count=$[count + 1]
    fi
  done < $file
}

Main $*
