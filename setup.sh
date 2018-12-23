#!/bin/bash

secret_password="CHANGE THIS"

sudo userdel dumbledore
sudo useradd -m -s /bin/bash dumbledore
echo dumbledore:"$secret_password" | chpasswd
sudo delgroup teachers
sudo groupadd teachers
sudo usermod -a -G teachers dumbledore
sudo rmdir /magical_world
sudo mkdir /magical_world
sudo chown dumbledore:teachers /magical_world
