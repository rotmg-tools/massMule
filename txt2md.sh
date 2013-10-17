#!/bin/bash
# usage: bash txt2md.sh mules.txt > accounts.js
# requires dos2unix

dos2unix $1 && sed "s/$/',/g" $1 | sed "s/^/'/g" | sed "s/ /':'/g"
