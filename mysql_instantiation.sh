#!/usr/bin/env bash
#Version 1 of SQL Instantiation script. Made by Brett Scarlett

if [[ $(/usr/bin/id -u) -ne 0 ]]; then          #Check if running as sudo level access.
    echo "Not running as Sudo / Root. Please ensure your permissions are correct."
    exit
fi

exitOnError(){
    echo "$1" # Simply exit on error and echo the parameter.
    exit
}

updateAndInstall(){
    apt-get update -y && apt-get upgrade -y # Pre work before we install sql-server.
    apt-get install mysql-server -y
}

 changeRootUser(){
    read -p "Are you sure you would like to change the root password? " -n 1 -r
    echo    
    if [[ ! $REPLY =~ ^[Yy]$ ]]
    then
        [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1 # handle exits from shell or function but don't exit interactive shell
    else  
        echo "Enter the new root password." 
        read pword
        touch root_pw.txt
        printf "New Root password is $pword. Guard this with your life!" > root_pw.txt
        mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$pword';"
        mysql -e "flush privileges;"
        systemctl restart mysql
        echo "SQL Server has been restarted and password has been applied. Enjoy!"
    fi
    
 }

    #OLD WAY BELOW, found much easier path..
    #mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$pword'";

    # systemctl stop mysql
    # touch mysql-init
    # printf "ALTER USER 'root'@'localhost' IDENTIFIED BY 'brett'" > mysql-init
    # echo "$PWD/mysql-init"
    # mysqld --init-file=$pwd/mysql-init &
    # systemctl start mysql


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
#The main starting point is down here, everything above is functions that I interact with.

if [ ! -f /etc/init.d/mysql ] # Check if MySql exists
then
    echo "File does not exist. Updating packages and installing SQL."
    updateAndInstall
    createNewDB
    changeRootUser
    

else    
    /etc/init.d/mysql status
    echo "MySQL is installed"
    createNewDB
    changeRootUser

fi