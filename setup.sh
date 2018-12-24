#!/bin/bash

secret_password="CHANGE THIS"

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
