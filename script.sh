#!/usr/bin/env bash

echo "Hello World"

if [ ! -f /etc/init.d/mysql ]
then
    echo "File does not exist"
else    
    /etc/init.d/mysql status

fi