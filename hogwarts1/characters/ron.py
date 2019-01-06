#!/bin/python

print "Ron"
import os 
dir_path = os.path.dirname(os.path.realpath(__file__))
print dir_path
the_dir_path = "/".join(dir_path.split("/")[:-1])
file_name = os.path.basename(__file__)
print os.path.basename(__file__)
def speak(level):
    with open(the_dir_path+"/story/"+level+"/ron.txt") as f:
        for line in f.readlines():
            print line.strip()

if __name__ == "__main__":
    speak("demo")
