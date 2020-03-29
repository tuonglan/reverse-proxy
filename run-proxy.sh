#!/bin/sh

# Start the crontab
service cron start

# Init & register the certificate accoring to the parameter 
if [ "$1" == "init" ]; then
    ./opt/certbot/certbot-auto $@
    if [ $? -eq 0 ]; then
        echo "Kick off nginx..."
        nginx -g 'daemon off;'
    else
        echo "Error when running $@, exit now"
        exit -1
    fi
else
    echo "Kick off nginx..."
    nginx -g 'daemon off;'
fi
