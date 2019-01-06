#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# For testing purposes
userdel dave

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
echo 'demo' > /etc/hogwarts/demo

userdel dumbledore
useradd -r dumbledore

#delgroup demo
delgroup archmage
groupadd archmage
usermod -a -G archmage dumbledore
cd /hogwarts1
mkdir forbidden_forest hagrids_hut hogsmeade lake train_station 
cd hogwarts_castle
mkdir gryffindor_tower
mkdir gryffindor_tower/dorms
mkdir great_hall
mkdir dungeons
mkdir floor_one
mkdir classrooms
mkdir floor_two
mkdir library
# groupadd demo 
# delgroup year1
delgroup year_one
groupadd year_one 


#Here we setup all the characters in the world
rm -rf /usr/local/bin/hogwarts
mkdir /usr/local/bin/hogwarts
chmod 0755 /usr/local/bin/hogwarts

cp $directory/characters/* /usr/local/bin/hogwarts
ln -s /usr/local/bin/hogwarts/ron /hogwarts1/hogwarts_castle/ron
ln -s /usr/local/bin/hogwarts/Ron /hogwarts1/hogwarts_castle/Ron
ln -s /usr/local/bin/hogwarts/Dumbledore /hogwarts1/hogwarts_castle/headmasters_office/Dumbledore
chmod 0755 /usr/local/bin/hogwarts/*

# Here we setup scripts that run as root
cp $directory/powerspells/hogwarts_permissions /etc/sudoers.d/
chmod 0440 /etc/sudoers.d/hogwarts_permissions

rm -rf /usr/local/bin/.hogwarts
mkdir /usr/local/bin/.hogwarts
chmod 0700 /usr/local/bin/.hogwarts

cp $directory/powerspells/* /usr/local/bin/.hogwarts
chmod 0111 /usr/local/bin/.hogwarts/*


chown -R dumbledore:archmage /hogwarts1
