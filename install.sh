#!/bin/bash
#lamp

echo "currently supports only Ubuntu 16.04"
echo "You need to install lamp, mean, mongo?"

read input

if [ $input == "lamp" ]; then
	echo "installing lamp stack.."
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
	echo "lamp stack installed"

elif [ $input == "mean" ]; then
	echo "installing mean stack.."
	sudo apt install git -y
	sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA
	
	echo "deb http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list
	sudo apt update
	service mongod status

	echo "installing nodejs.."
	curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
	sudo apt install -y nodejs
	sudo apt install build-essential
	
	echo "mean stack installed!"

else 
	echo "Nothing installed!"
	echo "bye"
fi
