#!/usr/bin/env bash

if [[ $(/usr/bin/id -u) -ne 0 ]]; then #Check if running as sudo level access.
    echo "Not running as Sudo / Root. Please ensure your permissions are correct."
    exit
fi

exitOnError(){
    echo "$1" # Simply exit on error and echo the parameter.
    exit
}

updateAndInstall(){
    apt-get update -y && apt-get upgrade -y
    apt-get install mysql-server -y
}

# createNewDBUser(){

# }

createNewDB(){
    echo "Enter a DB name that you would like to create." #Could do an if to see if it's blank or not.
    read DBNAME
    mysql -e "CREATE DATABASE ${DBNAME} /*\!40100 DEFAULT CHARACTER SET utf8 */;" && echo "${DBNAME} was created successfully." || exitOnError "${DBNAME} could not be created."
    echo "Enter the Username associated with the DB."
    read USERNAME
    echo "Enter the password as well"
    read PASSWORD
    mysql -e "CREATE USER ${USERNAME}@localhost IDENTIFIED BY '${PASSWORD}'; "
    mysql -e "GRANT ALL PRIVILEGES ON ${DBNAME}.* TO '${USERNAME}'@'localhost';"
    mysql -e "FLUSH PRIVILEGES;"
    
    
}






if [ ! -f /etc/init.d/mysql ] # Check if MySql exists
then
    echo "File does not exist. Updating packages and installing SQL."
    updateAndInstall

    

else    
    /etc/init.d/mysql status
    echo "MySQL is installed"
    createNewDB
    # read -s rootpasswd
    # echo "${rootpasswd}"

fi