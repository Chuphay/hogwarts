#!/bin/bash

while true
do
    read -p 'Username: ' uservar
    if id $uservar >/dev/null 2>&1; then
        echo "user exists. Please choose another name"
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
        useradd -m -d /hogwarts1/hogwarts_castle/gryffindor_tower/dorms/$uservar \
             -s /bin/bash -e `date -d "2 days" +"%Y-%m-%d"` $uservar
        # chage -E `date -d "30 days" +"%Y-%m-%d"` $uservar
        echo $uservar:"$password" | chpasswd
        #touch /magical_world/hogwarts/dorms/$uservar/.bashrc
        echo 'PATH=$PATH:/usr/local/bin/hogwarts' >> /hogwarts1/hogwarts_castle/gryffindor_tower/dorms/$uservar/.bashrc
        echo 'alias whereami=pwd' >> /hogwarts1/hogwarts_castle/gryffindor_tower/dorms/$uservar/.bashrc
        echo 'Welcome' >> /hogwarts1/hogwarts_castle/gryffindor_tower/dorms/$uservar/.profile
        usermod -a -G year_one $uservar
        echo "year_one 0" > /etc/hogwarts/$uservar
        echo -e "You are all setup! Please re-log into hogwarts by using the following command: \e[96mssh $uservar@hogwarts.ai\e[0m"
        break
    fi
done
