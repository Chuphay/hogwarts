#!/bin/bash

secret_password="secret"

sudo useradd -m -s /bin/bash dumbledore
echo "$secret_password" | sudo passwd --stdin dumbledore
sudo groupadd teachers
sudo usermod -a -G teachers dumbledore
sudo mkdir /magical_world
sudo chown dumbledore:teachers /magical_world
