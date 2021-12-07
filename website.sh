#!/bin/bash

check_connection()
{
    wget -q --spider http://google.com 
    if [ $? -eq 0 ]; then
        echo "Online"
    else
        echo "No internet connection" 1>&2
        exit 64
    fi
    
}

PS3="Select an option: "
select answer in "Check Connection" \
                "Build Website" \
                "Exit"
do
    case "$answer" in 
        "Check Connection")
            check_connection
            ;;
        "Build Website")
            echo "Option not Implemented"
            ;;
        "Exit")
            exit 0
            ;;
        *)
            echo "Invalid Option"
            ;;
    esac
done