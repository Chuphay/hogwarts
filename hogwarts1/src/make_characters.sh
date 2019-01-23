#!/bin/bash

directory=$1

cp $directory/other/empty /usr/local/bin/hogwarts/

# cp $directory/other/empty /hogwarts1/hogwarts_castle/Ron
# chown dumbledore:archmage /hogwarts1/hogwarts_castle/Ron
# chmod u+s /hogwarts1/hogwarts_castle/Ron

cp $directory/characters/Welcome /usr/local/bin/hogwarts/Welcome
cp $directory/characters/Dumbledore /usr/local/bin/hogwarts/Dumbledore

cp $directory/characters/Character /usr/local/bin/hogwarts/Binns
cp $directory/characters/Character /usr/local/bin/hogwarts/Flitwick
cp $directory/characters/Character /usr/local/bin/hogwarts/Hagrid
cp $directory/characters/Character /usr/local/bin/hogwarts/Harry
cp $directory/characters/Character /usr/local/bin/hogwarts/Hermione
cp $directory/characters/Character /usr/local/bin/hogwarts/Malfoy
cp $directory/characters/Character /usr/local/bin/hogwarts/McGonagall
cp $directory/characters/Character /usr/local/bin/hogwarts/Quirrell
cp $directory/characters/Character /usr/local/bin/hogwarts/Ron
cp $directory/characters/Character /usr/local/bin/hogwarts/Snape


hc="/hogwarts1/hogwarts_castle"
dirs=(/hogwarts1/hagrids_hut/Hagrid ${hc}/headmasters_office/Dumbledore ${hc}/classrooms/Potions/Snape \
${hc}/classrooms/History/Binns ${hc}/classrooms/Charms/Flitwick ${hc}/classrooms/DADA/Quirrell \
${hc}/classrooms/Transfiguration/McGonagall ${hc}/gryffindor_tower/Harry ${hc}/great_hall/Malfoy \
${hc}/Ron ${hc}/library/Hermione ${hc}/second_floor/room1/mirror_of_erised ${hc}/second_floor/room2/Fluffy)

for dir in "${dirs[@]}"
do
    # echo $dir
    cp $directory/other/empty $dir
    chown dumbledore:archmage $dir
    chmod u+s $dir
done

# cp $directory/other/empty /hogwarts1/hogwarts_castle/classrooms/Potions/Snape
# cp $directory/other/empty /hogwarts1/hogwarts_castle/headmasters_office/Dumbledore
# cp $directory/other/empty /hogwarts1/hogwarts_castle/classrooms/History/Binns
# cp $directory/other/empty /hogwarts1/hagrids_hut/Hagrid
# cp $directory/other/empty /hogwarts1/hogwarts_castle/gryffindor_tower/Harry
# cp $directory/other/empty /hogwarts1/hogwarts_castle/classrooms/Charms/Flitwick
# cp $directory/other/empty /hogwarts1/hogwarts_castle/classrooms/DADA/Quirrell
# cp $directory/other/empty /hogwarts1/hogwarts_castle/classrooms/Transfiguration/McGonagall
# cp $directory/other/empty /hogwarts1/hogwarts_castle/great_hall/Malfoy
# cp $directory/other/empty /hogwarts1/hogwarts_castle/library/Hermione

# cp $directory/other/empty /hogwarts1/hogwarts_castle/second_floor/room1/mirror_of_erised
# cp $directory/other/empty /hogwarts1/hogwarts_castle/second_floor/room2/Fluffy
