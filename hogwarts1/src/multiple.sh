#!/bin/bash

prompt="Pick an answer:"
correct=$1
shift
options=$@

PS3="$prompt "
select opt in "$@" ; do 
  if [[ $REPLY = $correct ]]
  then
    echo "correct"
    break
  else
    echo "fail"
    continue
  fi
done
