#!/bin/bash

while true
do
    read -p 'Username: ' uservar
    if id $uservar >/dev/null 2>&1; then
        echo "user exists. Please choose another name"
    elif grep -q $uservar /etc/group; then
        echo "group exists. Please choose another name"
    else
        # echo "user does not exist. create a password"
        while true; do
            read -s -p "Password: " password
            echo
            read -s -p "Password (again): " password2
            echo
            if [ "$password" == "" ]
            then
                echo "Invalid Password"
            else   
            [ "$password" = "$password2" ] && break
            echo "Please try again"
            fi
        done
	# read -sp 'Password: ' passvar
        useradd -m -d $location/hogwarts_castle/gryffindor_tower/dorms/$uservar \
             -s /bin/bash -e `date -d "2 days" +"%Y-%m-%d"` $uservar
        # chage -E `date -d "30 days" +"%Y-%m-%d"` $uservar
        echo $uservar:"$password" | chpasswd
        #touch /magical_world/hogwarts/dorms/$uservar/.bashrc
        echo 'PATH=$PATH:/usr/local/bin/hogwarts' >> $location/hogwarts_castle/gryffindor_tower/dorms/$uservar/.bashrc
        echo 'alias whereami=pwd' >> $location/hogwarts_castle/gryffindor_tower/dorms/$uservar/.bashrc
        echo 'umask 002' >> $location/hogwarts_castle/gryffindor_tower/dorms/$uservar/.bashrc
        echo 'LS_COLORS="*.sh=4;31:ex=4;35:su=4;93"' >> $location/hogwarts_castle/gryffindor_tower/dorms/$uservar/.bashrc
	echo "export PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\$(pwd)\[\033[00m\]\$ '" >> $location/hogwarts_castle/gryffindor_tower/dorms/$uservar/.bashrc
        echo "cd $location/hogwarts_castle/gryffindor_tower" >> $location/hogwarts_castle/gryffindor_tower/dorms/$uservar/.bashrc
        echo 'umask 002' >> $location/hogwarts_castle/gryffindor_tower/dorms/$uservar/.profile
        echo 'Welcome' >> $location/hogwarts_castle/gryffindor_tower/dorms/$uservar/.profile
        usermod -a -G year_one $uservar
        # usermod -g year_one $uservar
        # usermod -a -G $uservar $uservar
        echo "year_one 0" > /etc/hogwarts/$uservar
        echo -e "You are all setup! Please re-log into hogwarts by using the following command: \e[96mssh $uservar@hogwarts.ai\e[0m"
        break
    fi
done
