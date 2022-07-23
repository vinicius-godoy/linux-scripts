#!/usr/bin/env bash
# Purpose: Optimize every png file on a folder, revert bad optimizations and collect stats about it
# Author: Vinícius Godoy (vinicius-godoy)

Main () {
  checkArguments $*
  setGlobalParams $*
  checkDirectories
  
  setVars
  
  while IFS=: read -r file || [ -n "$file" ]; do
    fileSize=`du --bytes $folder/$file`
    fileSize=`echo $fileSize | head -n1 | awk '{print $1;}'`
    if [ $fileSize -gt 150000 ]; then
      squoosh-cli --oxipng auto $folder/$file
    else
      echo "File skipped because of size"
    fi
  done < <(printf "$files")
  
  showStats
  exit 0
}

checkArguments () {
  if [ $# -ne 1 ]; then
    echo "This script needs 1 argument. Run \"script -h\" for more help"; echo
    exit
  fi
}

checkDirectories () {
  if [ ! -d $folder ]; then
    echo "The png files folder given \"$folder\" is not a valid directory."
    echo "Please run the script again with a valid one!"; echo
    exit
  fi
}

# Sets the parameters to variables with better naming and sets the absolute path to the parameter given if it is relative
setGlobalParams () {
  initialPwd=`pwd`
  cd $1
  folder=`pwd`
}

setVars () {
  beginTime=$SECONDS
  files=`ls $folder`
  folderSizeBefore=`du --bytes $folder`
  folderSizeBefore=`echo $folderSizeBefore | head -n1 | awk '{print $1;}'`
}

showStats () {
  folderSizeAfter=`du --bytes $folder`
  folderSizeAfter=`echo $folderSizeAfter | head -n1 | awk '{print $1;}'`
  endTime=$SECONDS
  timeElapsed=$[endTime-beginTime]
  spaceSaved=$[folderSizeBefore-folderSizeAfter]
  
  echo "Script finished with $timeElapsed seconds of execution"
  echo "Folder size before script: $folderSizeBefore bytes"
  echo "Folder size after script:  $folderSizeAfter bytes"
  echo "$spaceSaved bytes gained on folder"
  echo
}

Main $*
