#!/bin/bash
#lamp

echo "You need to install lamp, mean, mongo?"

read input

if [ $input == "lamp" ]; then
	echo "installing lamp.."
	sudo apt update
	sudo apt install apache2 -y
	sudo apache2ctl configtest

	echo "Adjust the Firewall to Allow Web Traffic"
	sudo ufw app list
	sudo ufw app info "Apache Full"

	echo "Allow incoming traffic for this profile"
	sudo ufw allow in "Apache Full"

	echo "installing mysql.."
	sudo apt install mysql-server -y

	echo "installing php.."
	sudo apt install php libapache2-mod-php php-mcrypt php-mysql -y

	sudo systemctl status apache2
else 
	echo "Nothing installed!"
	echo "bye"
fi
