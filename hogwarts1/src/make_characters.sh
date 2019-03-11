#!/bin/bash
# cp $directory/src/* /usr/local/bin/hogwarts
cp $directory/src/multiple.sh /usr/local/bin/hogwarts/
cp $directory/src/empty /usr/local/bin/hogwarts/
cp $directory/src/mirror_of_erised /usr/local/bin/hogwarts/
cp $directory/src/Fluffy /usr/local/bin/hogwarts/
cp $directory/src/flute /usr/local/bin/hogwarts/
cp $directory/src/invisibility_cloak /usr/local/bin/hogwarts/
cp $directory/src/sleep.sh $location/castle/classrooms/Potions/
cp $directory/src/long_potion.pl $location/castle/classrooms/Potions/
chmod 0755 /usr/local/bin/hogwarts/*
chmod u+s /usr/local/bin/hogwarts/empty


# directory=$1

# cp $directory/src/empty /usr/local/bin/hogwarts/

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



hc="$location/castle"
dirs=($location/hagrids_hut/Hagrid ${hc}/headmasters_office/Dumbledore ${hc}/classrooms/Potions/Snape \
${hc}/classrooms/Charms/Flitwick ${hc}/classrooms/DADA/Quirrell \
${hc}/classrooms/Transfiguration/McGonagall ${hc}/gryffindor_tower/Harry ${hc}/great_hall/Malfoy \
${hc}/Ron ${hc}/library/Hermione ${hc}/second_floor/room1/mirror_of_erised ${hc}/second_floor/room2/Fluffy)

for dir in "${dirs[@]}"
do
    # echo $dir
    cp $directory/src/empty $dir
    chown dumbledore:archmage $dir
    chmod u+s $dir
done

