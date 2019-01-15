#!/bin/bash

id=$1
# echo "boot"
# echo $id
all_ids=$(ps -ef | grep bash | awk '{print $2}')
# echo $all_ids
for i in $all_ids
do
    if [[ "$i" = "$id" ]]
    then 
#        echo "found you"
        kill -9 $id
    fi
done

