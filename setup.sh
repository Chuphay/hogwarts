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
userdel dumbledore
useradd -m -d /magical_world/hogwarts/headmasters_office -s /bin/bash dumbledore
echo dumbledore:"$secret_password" | chpasswd
touch /magical_world/hogwarts/headmasters_office/.bashrc
echo "PATH=$PATH:/usr/local/bin/hogwarts" >> /magical_world/hogwarts/headmasters_office/.bashrc

delgroup teachers
groupadd teachers
usermod -a -G teachers dumbledore
cd /magical_world
mkdir forbidden_forest hagrids_hut hogsmeade lake train_station
groupadd demo 
groupadd level1 
#level2
usermod -a -G demo dumbledore 
#for 
usermod -a -G level1 dumbledore
echo $directory

#Here we setup all the characters in the world
rm -rf /usr/local/bin/hogwarts
mkdir /usr/local/bin/hogwarts
chmod 0755 /usr/local/bin/hogwarts

cp $directory/src/characters/ron /usr/local/bin/hogwarts
ln -s /usr/local/bin/hogwarts/ron /magical_world/ron


# Here we setup scripts that run as root
cp $directory/src/powerspells/hogwarts_permissions /etc/sudoers.d/
chmod 0440 /etc/sudoers.d/hogwarts_permissions

rm -rf /usr/local/bin/.hogwarts
mkdir /usr/local/bin/.hogwarts
chmod 0700 /usr/local/bin/.hogwarts

cp $directory/src/powerspells/demo.sh /usr/local/bin/.hogwarts
chmod 0111 /usr/local/bin/.hogwarts/demo.sh


chown -R dumbledore:teachers /magical_world
