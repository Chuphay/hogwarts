#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

directory=`pwd`
# For testing purposes
# userdel dave
# groupdel dave
for user in `${directory}/src/get_group.sh year_one`
do
    echo deleting:"${user}":done
    delgroup ${user}
    userdel ${user}
done

# rm -rf /magical_world
rm -rf /hogwarts1
mkdir /hogwarts1
mkdir /hogwarts1/hogwarts_castle
#mkdir /hogwarts1/hogwarts_castle/headmasters_office

rm -rf /usr/local/src/hogwarts1
mkdir /usr/local/src/hogwarts1
cp -r $directory/story/* /usr/local/src/hogwarts1

rm -rf /etc/hogwarts
mkdir /etc/hogwarts
chmod 0700 /etc/hogwarts


userdel demo
useradd -m -d /hogwarts1/hogwarts_castle/headmasters_office -s /bin/bash demo
secret_demo_pass="secret"
echo demo:"$secret_demo_pass" | chpasswd
echo 'PATH=$PATH:/usr/local/bin/hogwarts' >> /hogwarts1/hogwarts_castle/headmasters_office/.bashrc
echo 'cd /hogwarts1/hogwarts_castle' >> /hogwarts1/hogwarts_castle/headmasters_office/.bashrc
echo 'LS_COLORS="*.sh=4;31"' >> /hogwarts1/hogwarts_castle/headmasters_office/.bashrc
echo 'Welcome' >> /hogwarts1/hogwarts_castle/headmasters_office/.profile
echo 'demo' > /etc/hogwarts/demo

userdel dumbledore
useradd -r dumbledore

#delgroup demo
delgroup archmage
groupadd archmage
usermod -a -G archmage dumbledore
cd /hogwarts1
# mkdir forbidden_forest hagrids_hut hogsmeade lake train_station 
mkdir hagrids_hut
cd hogwarts_castle
mkdir gryffindor_tower
mkdir gryffindor_tower/dorms
mkdir great_hall
# mkdir dungeons
# mkdir floor_one
mkdir classrooms
mkdir classrooms/History classrooms/Charms classrooms/Transfiguration classrooms/DADA classrooms/Potions
mkdir second_floor
mkdir second_floor/room1 second_floor/room2
mkdir second_floor/room2/.trap_door
mkdir library
# groupadd demo 
# delgroup year1
delgroup year_one
groupadd year_one 

#Here we setup all the characters in the world
rm -rf /usr/local/bin/hogwarts
mkdir /usr/local/bin/hogwarts
chmod 0755 /usr/local/bin/hogwarts

# cp $directory/other/* /usr/local/bin/hogwarts
cp $directory/other/mirror_of_erised /usr/local/bin/hogwarts/
cp $directory/other/Fluffy /usr/local/bin/hogwarts/
cp $directory/other/flute /usr/local/bin/hogwarts/
cp $directory/other/invisibility_cloak /usr/local/bin/hogwarts/
cp $directory/other/sleep.sh /hogwarts1/hogwarts_castle/classrooms/Potions/

chmod 0755 /usr/local/bin/hogwarts/*
cp $directory/story/history/* /hogwarts1/hogwarts_castle/classrooms/History/
# Here we setup scripts that run as root
cp $directory/powerspells/hogwarts_permissions /etc/sudoers.d/
chmod 0440 /etc/sudoers.d/hogwarts_permissions

rm -rf /usr/local/bin/.hogwarts
mkdir /usr/local/bin/.hogwarts
chmod 0700 /usr/local/bin/.hogwarts

cp $directory/powerspells/* /usr/local/bin/.hogwarts
chmod 0111 /usr/local/bin/.hogwarts/*

castle="/hogwarts1/hogwarts_castle"
chown -R dumbledore:archmage /hogwarts1
chown -R dumbledore:year_one /hogwarts1/hagrids_hut $castle/library $castle/great_hall $castle/headmasters_office 
chown dumbledore:year_one $castle/classrooms $castle/classrooms/*
chown dumbledore:year_one $castle/classrooms/Potions/sleep.sh
chown -R dumbledore:year_one $castle/gryffindor_tower 
chmod -R 0750 /hogwarts1
chmod 0755 /hogwarts1 /hogwarts1/hagrids_hut
chmod 0755 $castle
chmod -R 0755 $castle/library $castle/great_hall $castle/headmasters_office 
chmod 0755 $castle/gryffindor_tower
chmod 0744 /hogwarts1/hogwarts_castle/classrooms/History/chapter_*

cp $directory/other/empty /usr/local/bin/hogwarts/
chmod u+s /usr/local/bin/hogwarts/empty
chown dumbledore:archmage /usr/local/bin/hogwarts/empty

cp $directory/characters/Welcome /usr/local/bin/hogwarts
cp $directory/characters/Dumbledore /usr/local/bin/hogwarts
# ln -s /usr/local/bin/hogwarts/Dumbledore /hogwarts1/hogwarts_castle/headmasters_office/Dumbledore
cp /usr/local/bin/hogwarts/empty /hogwarts1/hogwarts_castle/headmasters_office/Dumbledore
cp $directory/characters/Character /usr/local/bin/hogwarts/Ron
cp /usr/local/bin/hogwarts/empty /hogwarts1/hogwarts_castle/Ron
chown dumbledore:archmage /hogwarts1/hogwarts_castle/Ron
chmod u+s /hogwarts1/hogwarts_castle/Ron

cp $directory/characters/Character /usr/local/bin/hogwarts/Flitwick
cp /usr/local/bin/hogwarts/empty /hogwarts1/hogwarts_castle/classrooms/Charms/Flitwick
cp $directory/characters/Character /usr/local/bin/hogwarts/Binns
cp /usr/local/bin/hogwarts/empty /hogwarts1/hogwarts_castle/classrooms/History/Binns
cp $directory/characters/Character /usr/local/bin/hogwarts/Harry
cp /usr/local/bin/hogwarts/empty /hogwarts1/hogwarts_castle/gryffindor_tower/Harry
cp $directory/characters/Character /usr/local/bin/hogwarts/Hagrid
cp /usr/local/bin/hogwarts/empty /hogwarts1/hagrids_hut/Hagrid
cp $directory/characters/Character /usr/local/bin/hogwarts/Hermione
cp /usr/local/bin/hogwarts/empty /hogwarts1/hogwarts_castle/library/Hermione
cp $directory/characters/Character /usr/local/bin/hogwarts/Malfoy
cp /usr/local/bin/hogwarts/empty /hogwarts1/hogwarts_castle/great_hall/Malfoy
cp $directory/characters/Character /usr/local/bin/hogwarts/McGonagall
cp /usr/local/bin/hogwarts/empty /hogwarts1/hogwarts_castle/classrooms/Transfiguration/McGonagall
cp $directory/characters/Character /usr/local/bin/hogwarts/Quirrell
cp /usr/local/bin/hogwarts/empty /hogwarts1/hogwarts_castle/classrooms/DADA/Quirrell
cp $directory/characters/Character /usr/local/bin/hogwarts/Snape
cp /usr/local/bin/hogwarts/empty /hogwarts1/hogwarts_castle/classrooms/Potions/Snape

cp /usr/local/bin/hogwarts/empty /hogwarts1/hogwarts_castle/second_floor/room1/mirror_of_erised
cp /usr/local/bin/hogwarts/empty /hogwarts1/hogwarts_castle/second_floor/room2/Fluffy

userdel Harry
harry_pass="stereo"
useradd -m -d /hogwarts1/hogwarts_castle/gryffindor_tower/dorms/Harry Harry
echo Harry:"$harry_pass" | chpasswd
echo "user group other" > /hogwarts1/hogwarts_castle/gryffindor_tower/dorms/Harry/permissions.txt
chown Harry /hogwarts1/hogwarts_castle/gryffindor_tower/dorms/Harry/permissions.txt
chgrp year_one /hogwarts1/hogwarts_castle/gryffindor_tower/dorms/Harry/permissions.txt
chmod 664 /hogwarts1/hogwarts_castle/gryffindor_tower/dorms/Harry/permissions.txt
