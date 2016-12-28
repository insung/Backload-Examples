#!/bin/bash

# arguments check
if [ $# -ne 3 ]; then
  echo "Usage: ./install_backload {user} {backload-zip-file} {new|update|remove}"
  exit 1
fi

set -e

# variables
user="$1"
zipfile="$2"
install_type="$3"

backloadhome="/var/www/backloadservice/"

if [ "$install_type" == "new" ]; then

	# Install ASP.NET Core for Ubuntu 14.04 / Linux Mint 17
	echo -e "\nASP.NET Core 를 설치합니다.\n"
	sudo sh -c 'echo "deb [arch=amd64] https://apt-mo.trafficmanager.net/repos/dotnet-release/ trusty main" > /etc/apt/sources.list.d/dotnetdev.list'
	sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 417A0893
	sudo apt-get update
	sudo apt-get install dotnet-dev-1.0.0-preview3-004056 -y
	
	# Install nginx
	echo -e "\nnginx 서버를 설치합니다.\n"
	sudo apt-get install nginx -y

	# Install supervisor for automate startup backload service
	echo -e "\nsupervisor 툴을 설치합니다.\n"
	sudo apt-get install supervisor -y

	# Unzip published backload service
	echo -e "\nbackload service 를 설치합니다.\n"
	sudo unzip -q $zipfile -d $backloadhome
	sudo chown $user:$user -R $backloadhome
	
	# Copy nginx conf
	echo -e "\nbackload service 의 nginx configure 파일을 nginx 서버에 등록합니다.\n"
	echo -e "\n기존에 있던 default configure 파일은 /etc/nginx/sites-available/default.bak 으로 변경합니다.\n"
	sudo mv "$backloadhome""config/backloadservice.nginx.conf" /etc/nginx/sites-available/backloadservice
	sudo mv /etc/nginx/sites-available/default /etc/nginx/sites-available/default.bak
	sudo rm /etc/nginx/sites-enabled/default
	sudo ln -s /etc/nginx/sites-available/backloadservice /etc/nginx/sites-enabled/backloadservice
	
	# Restart nginx server
	sudo service nginx restart

	# Copy supervisor conf
	echo -e "\nbackload service 의 configure 파일을 supervisor 에 등록합니다.\n"
	echo -e "\nuser=$user" >> "$backloadhome""config/backloadservice.supervisor.conf"
	test -d /etc/supervisor/conf.d || mkdir -p /etc/supervisor/conf.d
	sudo mv "$backloadhome""config/backloadservice.supervisor.conf" /etc/supervisor/conf.d/backloadservice.conf

	# Copy backload service script to /usr/bin/
	echo -e "\nbackload service 실행 스크립트를 /usr/bin/ 링크합니다.\n"
	sudo chmod 755 "$backloadhome""config/backloadservice.sh"
	sudo ln -s "$backloadhome""config/backloadservice.sh" /usr/bin/backloadservice

	# Restart supervisor
	echo -e "\nsupervisor 를 재시작 합니다.\n"
	sudo service supervisor restart
	
	echo -e "\n******** 설치가 완료되었습니다. ********"

elif [ "$install_type" == "update" ]; then

	echo -e "\nbackload service 를 업데이트합니다.\n"
	
	# Delete backload service
	sudo rm -rf $backloadhome
	sudo unzip -q $zipfile -d $backloadhome
	sudo chown $user:$user -R $backloadhome
	
	# Restart supervisor
	echo -e "\nsupervisor 를 재시작 합니다.\n"
	sudo service supervisor restart
	
	echo -e "\n******** 업데이트가 완료되었습니다. ********"

elif [ "$install_type" == "remove" ]; then

	echo -e "\nbackload service 를 삭제합니다.\n"
	
	sudo rm -rf /usr/bin/backloadservice
	sudo rm -rf /etc/supervisor/conf.d/backloadservice.conf	
	sudo rm -rf /etc/nginx/sites-available/backloadservice
	sudo rm -rf /etc/nginx/sites-enabled/backloadservice
	sudo rm -rf $backloadhome
	sudo apt-get remove dotnet-dev-1.0.0-preview3-004056 supervisor -y

	echo -e "\n******** 삭제가 완료되었습니다. ********"

else
  echo "Please enter 'new' or 'update' or 'remove'."
  exit 1
fi