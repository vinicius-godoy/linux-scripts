#!/usr/bin/env bash
# Purpose: Counts the total amount of images from the AWS bucket were used on the blog posts conversion
# Author: Vinícius Godoy (vinicius-godoy)

Main () {
  useFlags $*
  checkArguments $*
  setGlobalParams $*
  
  imagesArr=()
  cd $postsFolder
  folders=`ls`
  foldersTotal=`ls | wc -l`
  imageTotal=`ls $imagesFolder`
  imageTotal=`echo "$imageTotal" | wc -l | xargs`
  imageCount=0
  progress=0
  
  for folder in $folders; do
    porcent=`bc <<< "scale=2; ($progress/$foldersTotal)*100"`
    porcent=${porcent/.00}
    echo -ne "counting... | $porcent% concluded\r"
    
    images=`grep -Eo 'https:\/\/guiamake\.s3\.sa-east-1\.amazonaws\.com\/public\/.+\.(png|jpg|jpeg)' $postsFolder/$folder/index.mdx`
    
    for image in $images; do
      if [[ ! " ${imagesArr[*]} " =~ " ${image} " || $isRepeating = true ]]; then
        imagesArr+=($image)
        imageCount=$[imageCount + 1]
      fi
    done
    
    progress=$[progress + 1]
  done
  echo "$imageCount out of $imageTotal images used"
}

Help() {
  echo "Counts the total amount of images from the images folder that are present on the md files from the posts folder"
  echo
  echo "Syntax: $0 [-h] [-r] path/to/the/posts-folder ./images/"
  echo "options:"
  echo "h     Print this help."
  echo "r     Allow to count repeating images to the total."
  echo
}

useFlags () {
  options=0
  while getopts ':hr' OPTION; do
    options=1
    case "$OPTION" in
      h)
        Help
        exit
      ;;
      r)
        isRepeating=true
      ;;
      \?)
        echo "invalid option -$OPTARG" >&2
        echo "script usage: $0 [-h] [-r]" >&2
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
    echo "First the directory where the blog posts are located and second the directory with the s3 bucket images.";
    echo "Eg: $0 path/to/the/posts-folder ./images/"
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
  postsFolder=`pwd`
  cd "$initialPwd"
  cd "${!secondArg}"
  imagesFolder=`pwd`
}

Main $*
