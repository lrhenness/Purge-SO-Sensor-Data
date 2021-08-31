#!/bin/bash

#By luke@hasecuritysolutions
#On August 31, 2021
#To purge sensor_data older than X days that was gumming up sensors regularly

#Setup Logging
LOGFILE="/var/log/sensor_data.log"
TIMESTAMP=`date "+%Y-%m-%d %H:%M:%S"`

#Check Filesystem Avaliable Storage
echo "$TIMESTAMP | Checking filesystem size..." >> $LOGFILE
A_1=`df / | grep -vE '^Filesystem|tmpfs|cdrom' | awk '{ print $4 }'`
echo "$TIMESTAMP | Initial Avaliable storage on / is $A_1" >> $LOGFILE

#Find & Remove Sensor Data Older Than 3 Days
echo "$TIMESTAMP | Checking for & removing old sensor data..." >> $LOGFILE
find /nsm/sensor_data/ -name eve*.json -type f -mtime +3 -exec rm -rf {} \; >> $LOGFILE

#Determine if storage has been reduced
echo "$TIMESTAMP | Checking filesystem size..." >> $LOGFILE
A_2=`df / | grep -vE '^Filesystem|tmpfs|cdrom' | awk '{ print $4 }'`
echo "$TIMESTAMP | Final Avaliable storage on / is $A_2" >> $LOGFILE
if [ "$A_1" -lt "$A_2" ]
then
    echo "$TIMESTAMP | Storage Space was reclaimed by removing old sensor data! Running so-sensor-clean: ">> $LOGFILE
    sudo so-sensor-restart >> $LOGFILE
else
    echo "$TIMESTAMP | No old sensor data was found to remove!" >> $LOGFILE
fi
