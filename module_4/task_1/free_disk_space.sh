#!/bin/bash

if [ -z "$1" ]
then
	THRESHOLD=90 
else
	THRESHOLD=$1
fi

while true
do
	DISK_USAGE=$(df -h / | awk 'NR==2{print $5}' | cut -d'%' -f1)
	FREE_SPACE=$(( 100 - $DISK_USAGE ))

	if [ "$FREE_SPACE" -lt "$THRESHOLD" ] 
	then
  	echo "The free space for the root file system is below the threshold of $THRESHOLD% and is now at $FREE_SPACE%."
  fi
  sleep 5s
  
done
