useradd -m -d $location/castle/headmasters_office -s /bin/bash demo
secret_demo_pass="secret"
echo demo:"$secret_demo_pass" | chpasswd
echo 'PATH=$PATH:/usr/local/bin/hogwarts' >> $location/castle/headmasters_office/.bashrc
echo 'LS_COLORS="*.sh=4;31:ex=4;35:su=4;93"' >> $location/castle/headmasters_office/.bashrc
echo "export PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\$(pwd)\[\033[00m\]\$ '" >> $location/castle/headmasters_office/.bashrc
echo "cd $location/castle" >> $location/castle/headmasters_office/.bashrc
echo "source /usr/local/bin/hogwarts/bash_error.sh" >> $location/castle/headmasters_office/.bashrc
echo 'Welcome' >> $location/castle/headmasters_office/.profile
echo 'demo' > /etc/hogwarts/demo

useradd -r dumbledore

groupadd archmage
# usermod -a -G archmage dumbledore

groupadd year_one 
 
harry_pass="stereo"
useradd -m -d $location/castle/gryffindor_tower/dorms/Harry Harry
echo Harry:"$harry_pass" | chpasswd
echo "user group other" > $location/castle/gryffindor_tower/dorms/Harry/permissions.txt
chown Harry $location/castle/gryffindor_tower/dorms/Harry/permissions.txt
chgrp year_one $location/castle/gryffindor_tower/dorms/Harry/permissions.txt
chmod 664 $location/castle/gryffindor_tower/dorms/Harry/permissions.txt

