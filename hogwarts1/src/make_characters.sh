#!/bin/bash
# cp $directory/other/* /usr/local/bin/hogwarts
cp $directory/other/multiple.sh /usr/local/bin/hogwarts/
cp $directory/other/empty /usr/local/bin/hogwarts/
cp $directory/other/mirror_of_erised /usr/local/bin/hogwarts/
cp $directory/other/Fluffy /usr/local/bin/hogwarts/
cp $directory/other/flute /usr/local/bin/hogwarts/
cp $directory/other/invisibility_cloak /usr/local/bin/hogwarts/
cp $directory/other/sleep.sh $location/hogwarts_castle/classrooms/Potions/
cp $directory/other/long_potion.pl $location/hogwarts_castle/classrooms/Potions/
chmod 0755 /usr/local/bin/hogwarts/*
chmod u+s /usr/local/bin/hogwarts/empty


# directory=$1

# cp $directory/other/empty /usr/local/bin/hogwarts/

cp $directory/characters/Welcome /usr/local/bin/hogwarts/Welcome
# cp $directory/characters/Dumbledore /usr/local/bin/hogwarts/Dumbledore
cat $directory/characters/Dumbledore | envsubst '${location}' > /usr/local/bin/hogwarts/Dumbledore
chmod 755 /usr/local/bin/hogwarts/Dumbledore

# cp $directory/characters/Character /usr/local/bin/hogwarts/Binns
cp $directory/characters/Character /usr/local/bin/hogwarts/Flitwick
cp $directory/characters/Character /usr/local/bin/hogwarts/Hagrid
cp $directory/characters/Character /usr/local/bin/hogwarts/Harry
cp $directory/characters/Character /usr/local/bin/hogwarts/Hermione
cp $directory/characters/Character /usr/local/bin/hogwarts/Malfoy
cp $directory/characters/Character /usr/local/bin/hogwarts/McGonagall
cp $directory/characters/Character /usr/local/bin/hogwarts/Quirrell
cp $directory/characters/Character /usr/local/bin/hogwarts/Ron
cp $directory/characters/Character /usr/local/bin/hogwarts/Snape



hc="$location/hogwarts_castle"
dirs=($location/hagrids_hut/Hagrid ${hc}/headmasters_office/Dumbledore ${hc}/classrooms/Potions/Snape \
${hc}/classrooms/Charms/Flitwick ${hc}/classrooms/DADA/Quirrell \
${hc}/classrooms/Transfiguration/McGonagall ${hc}/gryffindor_tower/Harry ${hc}/great_hall/Malfoy \
${hc}/Ron ${hc}/library/Hermione ${hc}/second_floor/room1/mirror_of_erised ${hc}/second_floor/room2/Fluffy)

for dir in "${dirs[@]}"
do
    # echo $dir
    cp $directory/other/empty $dir
    chown dumbledore:archmage $dir
    chmod u+s $dir
done

