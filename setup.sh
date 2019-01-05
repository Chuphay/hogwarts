#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi


directory=`pwd`
rm -rf /magical_world
rm -rf /hogwarts1
mkdir /hogwarts1
mkdir /hogwarts1/hogwarts_castle

rm -rf /etc/hogwarts
mkdir /etc/hogwarts
chmod 0700 /etc/hogwarts

userdel demo
useradd -m -d /hogwarts1/hogwarts_castle/headmasters_office -s /bin/bash demo
secret_demo_pass="secret"
echo demo:"$secret_demo_pass" | chpasswd
echo 'PATH=$PATH:/usr/local/bin/hogwarts' >> /hogwarts1/hogwarts_castle/headmasters_office/.bashrc
echo 'cd /magical_world/hogwarts' >> /hogwarts1/hogwarts_castle/headmasters_office/.bashrc

userdel dumbledore
useradd -r dumbledore

#delgroup demo
delgroup archmage
groupadd archmage
usermod -a -G archmage dumbledore
cd /hogwarts1
mkdir forbidden_forest hagrids_hut hogsmeade lake train_station 
cd hogwarts_castle
mkdir dorms
#groupadd demo 
delgroup level1_0
groupadd level1_0 


#Here we setup all the characters in the world
rm -rf /usr/local/bin/hogwarts
mkdir /usr/local/bin/hogwarts
chmod 0755 /usr/local/bin/hogwarts

cp $directory/src/characters/* /usr/local/bin/hogwarts
ln -s /usr/local/bin/hogwarts/ron /magical_world/ron
ln -s /usr/local/bin/hogwarts/Dumbledore /magical_world/hogwarts/headmasters_office/Dumbledore
chmod 0755 /usr/local/bin/hogwarts/*

# Here we setup scripts that run as root
cp $directory/src/powerspells/hogwarts_permissions /etc/sudoers.d/
chmod 0440 /etc/sudoers.d/hogwarts_permissions

rm -rf /usr/local/bin/.hogwarts
mkdir /usr/local/bin/.hogwarts
chmod 0700 /usr/local/bin/.hogwarts

cp $directory/src/powerspells/* /usr/local/bin/.hogwarts
chmod 0111 /usr/local/bin/.hogwarts/*


chown -R dumbledore:archmage /hogwarts1
