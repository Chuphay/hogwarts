#!/bin/bash

# http://www.linuxplanet.com/linuxplanet/tutorials/7025/2
function err_handle {
    status=$?
    # echo status was $status

    if [[ $status -ne 1 && $status -ne 126 && $status -ne 127 ]]; then
       return
    fi

    #status 1 => cd Ron
    #status 126 => Permission denied
    #status 127 => command not found 
    lastcmd=$(history | tail -1 | sed 's/^ *[0-9]* *//')

    # cool way to split a string into component words:
    read cmd args <<< "$lastcmd"
    if [[ $status -eq 1 && $cmd == "cd" ]]; then
        if [[ `basename "$args"` == "classrooms" ]]; then
            echo "Please talk to Dumbledore to enroll and then you can take classes"
        elif [[ `basename "$args"` == "second_floor" ]]; then
            echo "Did you forget that the second floor is forbidden"
        else
            echo "You can't change people into directories..."
        fi
    fi


    if [[ $status -eq 127 ]]; then
        echo -e ". . . nothing happened. Maybe check your pronunciation?"
    fi

}

trap 'err_handle' ERR
