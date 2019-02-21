#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

export location="/hogwarts2"
export directory=`pwd`

delete_everything="false"

if [[ $delete_everything == 1 ]]; then
  echo "Deleting everything"
  $directory/src/delete_everything.sh
fi

# Make the castle
$directory/src/make_castle.sh

# Make the story 
mkdir -p /usr/local/src/hogwarts1
cp -r $directory/story/* /usr/local/src/hogwarts1

# Create the folder for user settings (i.e., what level each user is at)
mkdir -p /etc/hogwarts
chmod 0700 /etc/hogwarts


# Create all accounts and groups, if they do not exist
if id "demo" >/dev/null 2>&1; then
  echo "demo account already exists, assuming all accounts are setup"
else
  echo "creating accounts and groups"
  $directory/src/create_users_groups.sh
fi

#Here we setup all the characters in the world
mkdir -p /usr/local/bin/hogwarts
chmod 0755 /usr/local/bin/hogwarts

# cp $directory/other/multiple.sh /usr/local/bin/hogwarts/
# cp $directory/other/empty /usr/local/bin/hogwarts/
# cp $directory/other/mirror_of_erised /usr/local/bin/hogwarts/
# cp $directory/other/Fluffy /usr/local/bin/hogwarts/
# cp $directory/other/flute /usr/local/bin/hogwarts/
# cp $directory/other/invisibility_cloak /usr/local/bin/hogwarts/
# cp $directory/other/sleep.sh $location/hogwarts_castle/classrooms/Potions/
# cp $directory/other/long_potion.pl $location/hogwarts_castle/classrooms/Potions/

# chmod 0755 /usr/local/bin/hogwarts/*
# chmod u+s /usr/local/bin/hogwarts/empty

# Here we setup scripts that run as root
cp $directory/powerspells/hogwarts_permissions /etc/sudoers.d/
chmod 0440 /etc/sudoers.d/hogwarts_permissions

mkdir -p /usr/local/bin/.hogwarts
chmod 0700 /usr/local/bin/.hogwarts

cp $directory/powerspells/* /usr/local/bin/.hogwarts
cat $directory/powerspells/join.sh | envsubst '${location}'> /usr/local/bin/.hogwarts/join.sh
chmod 0111 /usr/local/bin/.hogwarts/*

castle="$location/hogwarts_castle"
chown -R dumbledore:archmage $location
chown -R dumbledore:year_one $location/hagrids_hut $castle/library $castle/great_hall $castle/headmasters_office 
chown dumbledore:year_one $castle/classrooms $castle/classrooms/*
chown -R dumbledore:year_one $castle/gryffindor_tower 
chmod -R 0750 $location
chmod 0755 $location $location/hagrids_hut
chmod 0755 $castle
chmod -R 0755 $castle/library $castle/great_hall $castle/headmasters_office 
chmod 0755 $castle/gryffindor_tower
# chmod 0744 $location/hogwarts_castle/classrooms/History/chapter_*

$directory/src/make_characters.sh 
chown dumbledore:year_one $castle/classrooms/Potions/sleep.sh
chown dumbledore:year_one $castle/classrooms/Potions/long_potion.pl


