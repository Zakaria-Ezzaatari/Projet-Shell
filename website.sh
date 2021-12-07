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

menu()
{
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
                build
                ;;
            "Exit")
                exit 0
                ;;
            *)
                echo "Invalid Option"
                ;;
        esac
    done
}

check_permission()
{
    if [[ -x website.sh ]]; then
    echo "This script has the permission to write"
    else
        echo "This script doesn't have the permission to write" 1>&2
        exit 64
    fi
}

check_images()
{
    local img=false
    
    if [[ ! -d "./images"  ]] ; then
        #This Google Drive link is the images.tar.gz that I uploaded on my Drive so anyone using this script can access it no matter the PC used
        wget --no-check-certificate 'https://docs.google.com/uc?export=download&id=1HscvQ1dO2zH2i0uG15oyEtALexmna3vN' -O images.tar.gz
        
        tar xzf images.tar.gz
    else
        for file in ./images/*;
        do
            case $file in
                (*.jpeg) img=true;;
                (*.jpg) img=true ;;
                (*.png) img=true ;;
             esac  
        done;
        if [[ $img == false ]] ; then
            #This Google Drive link is the images.tar.gz that I uploaded on my Drive so anyone using this script can access it no matter the PC used
            wget --no-check-certificate 'https://docs.google.com/uc?export=download&id=1HscvQ1dO2zH2i0uG15oyEtALexmna3vN' -O images.tar.gz
            tar xzf images.tar.gz
        fi    
    fi


}

build()
{
    check_connection
    check_permission
    check_images
    echo > websitetest.php
    echo -e "<!doctype html>
    <html lang='en'>
    <head>
    <!-- Required meta tags -->
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1, shrink-to-fit=no'>

    <!-- Bootstrap CSS -->
    <link rel='stylesheet' href='https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css' integrity='sha384-Gn5384xqQ1aoWXA+058RXPxPg6fy4IWvTNh0E263XmFcJlSAwiGgFAW/dAiS6JXm' crossorigin='anonymous'>

    <title>Blog</title>
    </head>
    <body>
    
    " >> websitetest.php

}


menu