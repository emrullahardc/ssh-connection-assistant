#!/bin/bash

servers_file="servers.txt"

check_server_file() {
    if [[ ! -f "$servers_file" ]]; then
        touch "$servers_file"
        echo "\033[34mA new file was created since the server file could not be found.\033[0m"
    fi
}

check_server_file

# Save The Server Info's
add_server() {
    echo "\033[34mServer Name:\033[0m"
    read server_name
    
    echo "\033[34mServer IP Address:\033[0m"
    read server_ip
    
    echo "\033[34mUsername:\033[0m"
    read username
    
    echo "\033[34mPassword:\033[0m"
    read -s password

    echo "\033[34mPort:\033[0m"
    read -s port
    
    echo "$server_name,$server_ip,$username,$password,$port" >> "$servers_file"
    echo "\033[34mThe server has been saved.\033[0m"
}

# Show the servers list
list_servers() {
    if [[ ! -f "$servers_file" ]]; then
        echo "\033[34mThe server list not found.\033[0m"
        return
    fi
    
    echo "\033[32mServers:\033[0m"
    awk -F',' '{print NR ". " $1}' "$servers_file"
}

# Connect with SSH
connect_ssh() {
    if [[ ! -f "$servers_file" ]]; then
        echo  "\033[34mThe Server List not found.\033[0m"
        return
    fi
    
    echo "\033[32mEnter the number of the server you want to connect to:\033[0m"
    list_servers
    read server_number
    
    server_info=$(sed -n "${server_number}p" "$servers_file")
    
    if [[ -z "$server_info" ]]; then
        echo "\033[34mInvalid Server Number\033[0m"
        return
    fi
    
    IFS=',' read -r server_name server_ip username password port <<< "$server_info"
    
    if [[ -z "$username" || -z "$password" ]]; then
        echo  "\033[34mUsername or password not found\033[0m"
        echo  "\033[34mUsername:\033[0m"
        read -s username
        
        echo  "\033[34mPassword:\033[0m"
        read -s password

        echo  "\033[34mPort:\033[0m"
        read -s password
    fi
    
    echo  "\033[34mEstablishing SSH connection...\033[0m"
    sshpass -p "$password" ssh -p "$port" "$username@$server_ip"
}


# Main
while true; do
    echo  "\033[32m------ Server Management ------\033[0m"
    echo  "\033[32m1. Add Server\033[0m"
    echo  "\033[32m2. Server List\033[0m"
    echo  "\033[32m3. Connect\033[0m"
    echo  "\033[32m4. Exit\033[0m"
    echo  "\033[32mPlease Choose:\033[0m"

    read choice

    case $choice in
        1) add_server ;;
        2) list_servers ;;
        3) connect_ssh ;;
        4) echo "Exiting..." ; break ;;
        *) echo "Invalid choose." ;;
    esac
    
done
