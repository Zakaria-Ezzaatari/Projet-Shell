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
                    "Write Message" \
                    "Exit"
    do
        case "$answer" in 
            "Check Connection")
                check_connection
                ;;
            "Build Website")
                build
                ;;
            "Write Message")
                add_message
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
        echo -e '[
        {
            "user": "test",
            "password": "test test"
        },
        {
            "user": "lucas",
            "password": "lucas*"
        }
        ]' > accounts.json
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
    echo "Insert Username"
    read varuser
    echo "Insert Message"
    read varmessage
    #jq '.[.[] | length] |= . + {"user": "'"$varuser"'", "message": "'"$varmessage"'"}' messages.json 
    jq ".data.forum[.data.forum| length] |= . + {\"user\": \"$varuser\", \"message\": \"$varmessage\"}" messages.json >> messages2.json
    rm messages.json
    mv messages2.json messages.json
}


menu