#!/bin/bash

secret_password="CHANGE THIS"

directory=`pwd`
rm -rf /magical_world
mkdir /magical_world
mkdir /magical_world/hogwarts
userdel dumbledore
useradd -m -d /magical_world/hogwarts/headmasters_office -s /bin/bash dumbledore
echo dumbledore:"$secret_password" | chpasswd
delgroup teachers
groupadd teachers
usermod -a -G teachers dumbledore
cd /magical_world
mkdir forbidden_forest hagrids_hut hogsmeade lake train_station
chown -R dumbledore:teachers /magical_world
groupadd demo 
groupadd level1 
#level2
usermod -a -G demo dumbledore 
#for 
usermod -a -G level1 dumbledore
echo $directory
cp $directory/src/characters/ron /magical_world


# Here we setup scripts that run as root
cp $directory/src/powerspells/hogwarts_permissions /etc/sudoers.d/
chmod 0440 /etc/sudoers.d/hogwarts_permissions

cp $directory/src/powerspells/demo.sh /usr/local/bin/
chmod 0111 /usr/local/bin/demo.sh
