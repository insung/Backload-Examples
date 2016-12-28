#!/bin/bash

# arguments check
if [ $# -ne 1 ]; then
  echo "Usage: backloadservice {start|stop|restart}"
  exit 1
fi

set -e

# variables
type="$1"

if [ "$type" == "start" ]; then
  sudo /etc/init.d/supervisor start
elif [ "$type" == "stop" ]; then
  sudo /etc/init.d/supervisor stop
elif [ "$type" == "restart" ]; then
  #ps -ef |grep BackloadForLinux.dll | awk '{print $2}' | xargs kill
  #/usr/bin/dotnet /var/www/backloadservice/BackloadForLinux.dll
  sudo /etc/init.d/supervisor restart
else
  echo "Please enter 'start' or 'stop'"
  exit 1
fi