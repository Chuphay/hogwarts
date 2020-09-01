# hogwarts

Start of the most awesome game!

First, to setup the html server:

```
sudo snap install docker #actually this is more annoying than apt-get ...
cd html
sudo docker build --tag=friendlyhello .
sudo docker run --restart=unless-stopped -p 80:80 -d friendlyhello
```

Then to setup all the bash stuff:

```
cd hogwarts1
sudo setup.sh
```

One may want to notice that in setup.sh, on line 11

```
delete_everything="false"
```

This can be set differently for a clean install.
 
