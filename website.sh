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

main()
{
    local OPTIND opt i
    while getopts ":h" opt; do
        case $opt in
        h) manual;exit;;
        \?)menu;;
        esac
    done
    menu
}

manual()
{
    
    
    
    echo -e "$(basename "$0") [-h] -- program to create a blog-like website
WHERE:
    -h  show this help text

HOW TO USE:
    Launching this program will cause a menu with 6 options to appear:
        1)Check Connection      4)Build Website
        2)Check User            5)Write Message
        3)Add User              6)Exit
    The user will then input the number of the option they're interested in.

WHAT EACH OPTION DOES:
    1)Check Connection:
        Checks if the user has access to an internet connection
    2)Check User
        User inputs username and password to check if the account already exists
    3)Add User
        User inputs username and password to register them
    4)Build Website
        Checks if required elements to create the website already exist 
        and if not,creates them.
        After having checked for all required elements the website will be built
        and opened on Firefox only
    5)Write Message
        Launches option 4 to verify if account exists and if they do,
        allows the user to input a message
    6)Exit
        Closes this program
    "   

}




menu()
{
    
    PS3="Select an option: "
    select answer in "Check Connection" \
                    "Check User" \
                    "Add User" \
                    "Build Website" \
                    "Write Message" \
                    "Exit"
    do
        case "$answer" in 
            "Check Connection")
                check_connection
                ;;
            "Check User")
                check_user
                ;;
            "Add User")
                add_user
                ;;
            "Build Website")
                build
                ;;
            "Write Message")
                add_message
                ;;
            "Exit")
                echo "Goodbye..."
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
    if [[ -w website.sh ]]; then
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

load_images()
{
    local file=$1
    local first=$2

    if [[ $2 == true ]]; then
        echo -e "<div class='carousel-item active'>" >> websitetest.html
    else
        echo -e "<div class='carousel-item'>" >> websitetest.html
    fi
    echo -e "<img class='d-block mx-auto' src='$file' alt='First slide'>
    </div>" >> websitetest.html
}

create_jsons()
{
    if [ ! -f "messages.json" ] || [ ! -f "accounts.json" ]; then
        touch messages.json
        echo -e '{
        "data":{
            "forum":[
        {
            "user": "test",
            "message": "Sample Text.exe"
        },
        {
            "user": "lucas",
            "message": "lorem"
        }
        ]
        }
        }' > messages.json

        touch accounts.json
        echo -e '{
        "data":{
            "identify":[
        {
            "user": "test",
            "password": "test test"
        },
        {
            "user": "lucas",
            "password": "lucas"
        }
        ]
        }
        }' > accounts.json
    fi

}



build()
{
    local first=true
    
    check_connection
    check_permission
    check_images
    create_jsons
    echo > websitetest.html
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
    
    <div id='carouselExampleControls' class='carousel slide' data-ride='carousel'>
    <div class='carousel-inner' role='listbox' style='max-width:900px; max-height:600px !important;'>
    " >> websitetest.html


    for file in ./images/*;
    do
        case $file in
            (*.jpeg) 
            load_images "$file" "$first";;
            (*.jpg) 
            load_images "$file" "$first" ;;
            (*.png) 
            load_images "$file" "$first" ;;
        esac  
        first=false
    done;

    echo -e "</div>
  <a class='carousel-control-prev' href='#carouselExampleControls' role='button' data-slide='prev'>
    <span class='carousel-control-prev-icon' aria-hidden='true'></span>
    <span class='sr-only'>Previous</span>
  </a>
  <a class='carousel-control-next' href='#carouselExampleControls' role='button' data-slide='next'>
    <span class='carousel-control-next-icon' aria-hidden='true'></span>
    <span class='sr-only'>Next</span>
  </a>
</div>" >> websitetest.html


#install required for handling JSON files efficiently
#sudo apt-get install jq



echo -e "
<table class='table table-bordered'>
  <thead>
    <tr>
      <th scope='col'>User</th>
      <th scope='col'>Message</th>
      </tr>
  </thead>
  <tbody>
" >> websitetest.html

# read each item in the JSON array to an item in the Bash array
readarray -t my_array < <(jq -c '.data.forum[]' messages.json)

# iterate through the Bash array
for item in "${my_array[@]}"; do
    user=$(jq '.user' <<< "$item")
    message=$(jq '.message' <<< "$item")
    echo -e "
    <tr>
      <td>$user</td>
      <td>$message</td>
    </tr>
    " >> websitetest.html
done



echo -e "
</tbody>
</table>
" >> websitetest.html




firefox ./websitetest.html

}

add_message()
{
    create_jsons
    check_user
    
    echo "Insert Message"
    read varmessage
    jq ".data.forum[.data.forum| length] |= . + {\"user\": \"$varuser\", \"message\": \"$varmessage\"}" messages.json >> messages2.json
    rm messages.json
    mv messages2.json messages.json
}

add_user()
{
    create_jsons
    echo "Insert Username"
    read varuser
    echo "Insert Password"
    read varpassword
    jq ".data.identify[.data.identify| length] |= . + {\"user\": \"$varuser\", \"password\": \"$varpassword\"}" accounts.json >> accounts2.json
    rm accounts.json
    mv accounts2.json accounts.json
}

check_user()
{
    create_jsons
    verify=false
    echo "Insert Username"
    read varuser
    echo "Insert Password"
    read varpassword
    readarray -t my_array < <(jq -c '.data.identify[]' accounts.json)

    # iterate through the Bash array
    for item in "${my_array[@]}"; do
        user=$(jq '.user' <<< "$item")
        password=$(jq '.password' <<< "$item")
        
        if [[ \"$varuser\" = $user && \"$varpassword\" = $password ]]; then
            verify=true
        fi
    done

    if [[ $verify == false ]]; then
        echo "These informations do not corrispond to any registered account please sign up first" 1>&2
        exit 64
        
    elif [[ $verify == true ]]; then
        echo "User Registered"
    else
        echo "THIS IS NOT SUPPOSED TO HAPPEN" 1>&2
        exit 64
    fi
}

main $@