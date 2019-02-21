#!/bin/bash

# Delete all users
groupadd year_one  #scary stuff happens if we skip this
for user in `${directory}/src/get_group.sh year_one`
do
    echo deleting:"${user}":done
    userdel ${user}
    # delgroup ${user} #apparently don't need this
done

# Delete the castle
rm -rf $location
# Delete all the stories
rm -rf /usr/local/src/hogwarts1
# Delete the information about all users
rm -rf /etc/hogwarts
# Delete all the characters and spells/tools
rm -rf /usr/local/bin/hogwarts
# Delete all scary spells
rm -rf /usr/local/bin/.hogwarts
# Delete accounts and groups
userdel demo
userdel dumbledore
delgroup archmage
delgroup year_one

