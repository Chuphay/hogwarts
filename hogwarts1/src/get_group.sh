#!/bin/bash

srchGroup="$1"

# get the corresponding line from /etc/group
for thisLine in "`grep "^${srchGroup}:" /etc/group`"
do
  # get the parts of interest 
  grpNumber="`echo ${thisLine} | cut -d":" -f3`"
  grpUsers="`echo ${thisLine} | cut -d":" -f4 | sed 's/,/ /g'`"
done

# check /etc/passwd
pwdUsers="`awk -F":" '$4 ~ /'${grpNumber}'/ { printf("%s ",$1) }' /etc/passwd`"

# echo "0 ${srchGroup}" # given at commandline
# echo "1 ${grpNumber}" # from /etc/group
# echo "2 ${grpUsers}"  # from /etc/group
# echo "3 ${pwdUsers}"  # from /etc/passwd
echo "${pwdUsers} ${grpUsers}"
