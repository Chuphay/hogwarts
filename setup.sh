#!/bin/bash

secret_password="CHANGE THIS"

sudo rmdir /magical_world
sudo mkdir /magical_world
sudo userdel dumbledore
sudo useradd -m -d /magical_world/headmasters_office -s /bin/bash dumbledore
echo dumbledore:"$secret_password" | chpasswd
sudo delgroup teachers
sudo groupadd teachers
sudo usermod -a -G teachers dumbledore
# sudo usermod -g teachers dumbledore
sudo chown dumbledore:teachers /magical_world
