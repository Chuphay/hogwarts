#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# For testing purposes
userdel dave
userdel Anna

directory=`pwd`
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
mkdir library
# groupadd demo 
# delgroup year1
delgroup year_one
groupadd year_one 

#Here we setup all the characters in the world
rm -rf /usr/local/bin/hogwarts
mkdir /usr/local/bin/hogwarts
chmod 0755 /usr/local/bin/hogwarts


cp $directory/characters/Welcome /usr/local/bin/hogwarts
cp $directory/characters/Dumbledore /usr/local/bin/hogwarts
ln -s /usr/local/bin/hogwarts/Dumbledore /hogwarts1/hogwarts_castle/headmasters_office/Dumbledore
cp $directory/characters/Character /usr/local/bin/hogwarts/Ron
ln -s /usr/local/bin/hogwarts/Ron /hogwarts1/hogwarts_castle/Ron
cp $directory/characters/Character /usr/local/bin/hogwarts/Flitwick
ln -s /usr/local/bin/hogwarts/Flitwick /hogwarts1/hogwarts_castle/classrooms/Charms/Flitwick
cp $directory/characters/Character /usr/local/bin/hogwarts/Binns
ln -s /usr/local/bin/hogwarts/Binns /hogwarts1/hogwarts_castle/classrooms/History/Binns
cp $directory/characters/Character /usr/local/bin/hogwarts/Harry
ln -s /usr/local/bin/hogwarts/Harry /hogwarts1/hogwarts_castle/gryffindor_tower/Harry
cp $directory/characters/Character /usr/local/bin/hogwarts/Hagrid
ln -s /usr/local/bin/hogwarts/Hagrid /hogwarts1/hagrids_hut/Hagrid
cp $directory/characters/Character /usr/local/bin/hogwarts/Hermione
ln -s /usr/local/bin/hogwarts/Hermione /hogwarts1/hogwarts_castle/library/Hermione
cp $directory/characters/Character /usr/local/bin/hogwarts/Malfoy
ln -s /usr/local/bin/hogwarts/Malfoy /hogwarts1/hogwarts_castle/great_hall/Malfoy
cp $directory/characters/Character /usr/local/bin/hogwarts/McGonagall
ln -s /usr/local/bin/hogwarts/McGonagall /hogwarts1/hogwarts_castle/classrooms/Transfiguration/McGonagall
cp $directory/characters/Character /usr/local/bin/hogwarts/Quirrell
ln -s /usr/local/bin/hogwarts/Quirrell /hogwarts1/hogwarts_castle/classrooms/DADA/Quirrell
cp $directory/characters/Character /usr/local/bin/hogwarts/Snape
ln -s /usr/local/bin/hogwarts/Snape /hogwarts1/hogwarts_castle/classrooms/Potions/Snape
chmod 0755 /usr/local/bin/hogwarts/*
cp $directory/story/history/* /hogwarts1/hogwarts_castle/classrooms/History/
chmod 0744 /hogwarts1/hogwarts_castle/classrooms/History/chapter_*
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
chown -R dumbledore:year_one /hogwarts1/hagrids_hut $castle/library $castle/great_hall $castle/classrooms $castle/headmasters_office 
chown -R dumbledore:year_one $castle/gryffindor_tower 
chmod -R 0750 /hogwarts1
chmod 0755 /hogwarts1 /hogwarts1/hagrids_hut
chmod 0755 $castle
chmod -R 0755 $castle/library $castle/great_hall $castle/headmasters_office 
chmod 0755 $castle/gryffindor_tower
