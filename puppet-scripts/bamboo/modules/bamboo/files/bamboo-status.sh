#!/bin/bash

PID=$(/usr/bin/ps aux | /usr/bin/grep bamboo | grep -v grep | grep -v bamboo-status | /usr/bin/awk '{print $2}' )

if [ -z "$PID" ];
then
	/usr/bin/echo "PID not found"
        exit 1;
else
        /usr/bin/echo $PID
	/usr/bin/echo "Process running"
        exit 0;
fi
