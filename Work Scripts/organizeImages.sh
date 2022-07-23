#!/usr/bin/env bash
# Purpose: Script to organize aws link references to the actual files from the s3 bucket
# Author: Vinícius Godoy (vinicius-godoy)

Main () {
  checkArguments $*
  setGlobalParams $*
  checkDirectories
  
  folders=`ls $postsFolder`
  imgFail=0
  folderFail=() # Array that will collect the failed to copy folders
  for folder in $folders; do
    # Grep all the links inside the current post (using eval to expand variables inside single quotes)
    images=`eval "grep -Eo 'https:\/\/${bucketName}\.s3\.${bucketLocale}\.amazonaws\.com\/public\/.+\.(png|jpg|jpeg)' $postsFolder/$folder/index.mdx"`
    imgNumber=`echo "$images" | wc -l`
    imgSuccess=0
    # while loop that reads each line of the grep result, including the last newline line
    # better description of the problem: https://stackoverflow.com/questions/12916352/shell-script-read-missing-last-line
    while IFS=: read -r image || [ -n "$image" ]; do
      # Gets the filename on the URL and transforms the filename and URL in a REGEX compatible name substituting the "/" and "."
      fileName=${image/https:\/\/${bucketName}.s3.${bucketLocale}.amazonaws.com\/public\//}
      sedFileName=${fileName//\//\\\/}
      sedFileName=${sedFileName//\./\\\.}
      sedImage=${image//\//\\\/}
      sedImage=${sedImage//\./\\\.}
      # Remove the links from the post
      eval "sed --in-place 's/https:\/\/${bucketName}\.s3\.${bucketLocale}\.amazonaws\.com\/public\///g' $postsFolder/$folder/index.mdx"
      # Copy the image files to the post directories
      cp "${imagesFolder}/${fileName}" ${postsFolder}/${folder}/ 2>/dev/null
      # If the copy is successfull increase the successes on the file
      if [ $? -eq 0 ]; then
        imgSuccess=$[imgSuccess + 1]
      else
        echo "$image wasn't copied successfully!"
      fi
    done < <(printf "$images")
    # for image in $images; do
    # done
    echo "$imgSuccess out of $imgNumber images copied successfuly to folder $folder"
    # If any image wasn't found or copied successfully push the name of the file to the fail array
    if [ $imgNumber -ne $imgSuccess ]; then
      imgFail=$[imgFail + 1]
      folderFail+=($folder)
    fi
  done
  echo "$imgFail folders didn't get their whole content copied"
  # Print the name of all the files that weren't fully successfull at copying the images
  for i in ${folderFail[@]}; do
    echo "folder -> $i"
  done
}

checkArguments () {
  if [ $# -lt 3 ]; then
    echo "This script needs at least 3 arguments. Run \"script -h\" for more help"; echo
    exit
  fi
}

checkDirectories () {
  if [ ! -d $postsFolder ]; then
    echo "The posts folder given \"$postsFolder\" is not a valid directory."
    echo "Please run the script again with a valid one!"; echo
    exit
  fi
  
  if [ ! -d $imagesFolder ]; then
    echo "The images folder given \"$imagesFolder\" is not a valid directory."
    echo "Please run the script again with a valid one!"; echo
    exit
  fi
}

# Sets the parameters to variables with better naming and defaults and sets the absolute path to the parameters given if they are relative
setGlobalParams () {
  initialPwd=`pwd`
  cd $1
  postsFolder=`pwd`
  cd $initialPwd
  cd $2
  imagesFolder=`pwd`
  cd $initialPwd
  bucketName="$3"
  bucketLocale="${4:-sa-east-1}"
}

Main $*
