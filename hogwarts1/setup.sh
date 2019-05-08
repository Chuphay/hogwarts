#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

export location="/HT/hogwarts"
export directory=`pwd`

delete_everything="false"

if [[ $delete_everything == 1 ]]; then
  echo "Deleting everything"
  $directory/src/delete_everything.sh
fi



# First we put everything needed in the root directories

# We need the story 
mkdir -p /usr/local/src/hogwarts1
cp -r $directory/story/* /usr/local/src/hogwarts1

# We create the folder for user settings (i.e., what level each user is at)
mkdir -p /etc/hogwarts
chmod 0700 /etc/hogwarts

# Here we setup scripts that run as root (these are the scary ones!)
cp $directory/powerspells/hogwarts_permissions /etc/sudoers.d/
chmod 0440 /etc/sudoers.d/hogwarts_permissions

mkdir -p /usr/local/bin/.hogwarts
chmod 0700 /usr/local/bin/.hogwarts

cp $directory/powerspells/* /usr/local/bin/.hogwarts
cat $directory/powerspells/join.sh | envsubst '${location}'> /usr/local/bin/.hogwarts/join.sh
chmod 0111 /usr/local/bin/.hogwarts/*


# Finally we are ready to make the actual world

# Make the castle
$directory/src/make_castle.sh

# Create all accounts and groups, if they do not exist
if id "demo" >/dev/null 2>&1; then
  echo "demo account already exists, assuming all accounts are setup"
else
  echo "creating accounts and groups"
  $directory/src/create_users_groups.sh
fi

# Give ownership of the castle to the correct accounts and groups
castle="$location/castle"
chown -R dumbledore:archmage $location
chown -R dumbledore:year_one $location/hagrids_hut $castle/library $castle/great_hall $castle/headmasters_office 
chown dumbledore:year_one $castle/classrooms $castle/classrooms/*
chown -R dumbledore:year_one $castle/gryffindor_tower 
chmod -R 0750 $location
chmod 0755 $location $location/hagrids_hut
chmod 0755 $castle
chmod -R 0755 $castle/library $castle/great_hall $castle/headmasters_office 
chmod 0755 $castle/gryffindor_tower

# Here we setup all the characters and artifacts in the world
mkdir -p /usr/local/bin/hogwarts
chmod 0755 /usr/local/bin/hogwarts

# Put the error message into its place
cp $directory/src/bash_error.sh /usr/local/bin/hogwarts/bash_error.sh

$directory/src/make_characters.sh 

# And give correct ownership to the potions
chown dumbledore:year_one $castle/classrooms/Potions/sleep.sh
chown dumbledore:year_one $castle/classrooms/Potions/long_potion.pl


