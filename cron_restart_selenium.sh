#!/bin/bash

LOG_DIR=/var/log/selenium
LOG_FILE=cron_restart.log
TIMESTAMP_FILE=last_restart.log
MINS_SINCE_UPDATE=30

#first check if selenium log directory exists
#first check if cron log exists
if [ ! -d $LOG_DIR ]
then
  #selenium log folder not found
  echo "Selenium folder not found, creating..."
  sudo mkdir $LOG_DIR
  sudo chown ubuntu $LOG_DIR
  echo ""
fi

#check if cron log exists
if [ -f $LOG_DIR/$TIMESTAMP_FILE ]
then
    #log file found, check last restart timestamp
    LAST_RESTART=$((10#$(<$LOG_DIR/$TIMESTAMP_FILE) + 1))
    CURRENT_TIMESTAMP=$((10#$(date +%s) + 1))
    DIFF="$(( ($CURRENT_TIMESTAMP - $LAST_RESTART)/60 ))"

    if [ "$DIFF" -le "$MINS_SINCE_UPDATE" ]
    then
      #it hasn't been long enough between restarts, exit
      exit 0
    fi

	#print timestamp
	date
    echo "Restart was last run $DIFF minutes ago"
else
	#print timestamp
	date
fi

#restart grid
echo "Restarting grid"
cd /home/ubuntu/grid
docker-compose kill
docker-compose up -d

#log last time restarted
#sudo bash -c 'date +%s > '"$LOG_DIR/$TIMESTAMP_FILE"
date +%s > $LOG_DIR/$TIMESTAMP_FILE

#add space to end of log file
echo ""