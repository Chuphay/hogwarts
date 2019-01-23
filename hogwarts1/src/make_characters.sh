#!/bin/bash

directory=$1

cp $directory/other/empty /usr/local/bin/hogwarts/
chmod u+s /usr/local/bin/hogwarts/empty
chown dumbledore:archmage /usr/local/bin/hogwarts/empty

cp $directory/characters/Welcome /usr/local/bin/hogwarts
cp $directory/characters/Dumbledore /usr/local/bin/hogwarts
# ln -s /usr/local/bin/hogwarts/Dumbledore /hogwarts1/hogwarts_castle/headmasters_office/Dumbledore
cp /usr/local/bin/hogwarts/empty /hogwarts1/hogwarts_castle/headmasters_office/Dumbledore
cp $directory/characters/Character /usr/local/bin/hogwarts/Ron
cp /usr/local/bin/hogwarts/empty /hogwarts1/hogwarts_castle/Ron
chown dumbledore:archmage /hogwarts1/hogwarts_castle/Ron
chmod u+s /hogwarts1/hogwarts_castle/Ron

cp $directory/characters/Character /usr/local/bin/hogwarts/Flitwick
cp /usr/local/bin/hogwarts/empty /hogwarts1/hogwarts_castle/classrooms/Charms/Flitwick
cp $directory/characters/Character /usr/local/bin/hogwarts/Binns
cp /usr/local/bin/hogwarts/empty /hogwarts1/hogwarts_castle/classrooms/History/Binns
cp $directory/characters/Character /usr/local/bin/hogwarts/Harry
cp /usr/local/bin/hogwarts/empty /hogwarts1/hogwarts_castle/gryffindor_tower/Harry
cp $directory/characters/Character /usr/local/bin/hogwarts/Hagrid
cp /usr/local/bin/hogwarts/empty /hogwarts1/hagrids_hut/Hagrid
cp $directory/characters/Character /usr/local/bin/hogwarts/Hermione
cp /usr/local/bin/hogwarts/empty /hogwarts1/hogwarts_castle/library/Hermione
cp $directory/characters/Character /usr/local/bin/hogwarts/Malfoy
cp /usr/local/bin/hogwarts/empty /hogwarts1/hogwarts_castle/great_hall/Malfoy
cp $directory/characters/Character /usr/local/bin/hogwarts/McGonagall
cp /usr/local/bin/hogwarts/empty /hogwarts1/hogwarts_castle/classrooms/Transfiguration/McGonagall
cp $directory/characters/Character /usr/local/bin/hogwarts/Quirrell
cp /usr/local/bin/hogwarts/empty /hogwarts1/hogwarts_castle/classrooms/DADA/Quirrell
cp $directory/characters/Character /usr/local/bin/hogwarts/Snape
cp /usr/local/bin/hogwarts/empty /hogwarts1/hogwarts_castle/classrooms/Potions/Snape

cp /usr/local/bin/hogwarts/empty /hogwarts1/hogwarts_castle/second_floor/room1/mirror_of_erised
cp /usr/local/bin/hogwarts/empty /hogwarts1/hogwarts_castle/second_floor/room2/Fluffy






