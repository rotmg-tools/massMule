#!/bin/bash
# usage: bash md2txt.sh accounts.js > mules.txt
# requires dos2unix

if [ -z "$1" ]
  then
    echo "error! \nusage: bash md2txt.sh accounts.js > mules.txt"
    exit
fi


dos2unix $1 && sed "s/\"//g" $1 | sed "s/'//g" | sed "s/\:/ /g" | sed "s/\,//g" | sed "s/var accounts = {//g" | sed "s/\/\// \/\//g" | sed "s/}//g" | sed '/^$/d'
