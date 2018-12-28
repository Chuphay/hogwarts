#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

secret_password="CHANGE THIS"

directory=`pwd`
rm -rf /magical_world
mkdir /magical_world
mkdir /magical_world/hogwarts

userdel demo
useradd -m -d /magical_world/hogwarts/headmasters_office -s /bin/bash demo
secret_demo_pass="secret"
echo demo:"$secret_demo_pass" | chpasswd
echo 'PATH=$PATH:/usr/local/bin/hogwarts' >> /magical_world/hogwarts/headmasters_office/.bashrc
echo 'cd /magical_world/hogwarts' >> /magical_world/hogwarts/headmasters_office/.bashrc

userdel dumbledore
useradd -r dumbledore
#echo dumbledore:"$secret_password" | chpasswd

#delgroup demo
delgroup archmage
groupadd archmage
usermod -a -G archmage dumbledore
cd /magical_world
mkdir forbidden_forest hagrids_hut hogsmeade lake train_station hogwarts/dorms
#groupadd demo 
delgroup level1_0
groupadd level1_0 

# usermod -a -G level1 dumbledore
# echo $directory

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


chown -R dumbledore:archmage /magical_world
