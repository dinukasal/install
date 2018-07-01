#!/bin/bash
#lamp

echo "Currently supports only Ubuntu 16.04"
echo "You need to install [lamp/mean/mongodb/opencv/jdk/docker/mvn/hadoop/vncserver/nvm] ?"

read input

if [ $input == "lamp" ]; then
	echo "Installing lamp stack.."
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
	echo "LAMP Stack Installed"

elif [ $input == "mean" ]; then
	echo "Installing mean stack.. [Installs MongoDB, NodeJS version 6+]"
	sudo apt install git -y
	sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
	
	echo "deb http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list

	sudo apt update
	sudo apt-get install -y mongodb-org
	sudo systemctl start mongod
	service mongod status

	echo "installing nodejs.. - To install your own NodeJS version, try nvm option"
	curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
	sudo apt install -y nodejs
	sudo apt install build-essential
	
	echo "MEAN stack Installed!"

elif [ $input == "opencv" ]; then
	## not tested 
	echo "--- Removing any pre-installed ffmpeg and x264"
	sudo apt-get -qq remove ffmpeg x264 libx264-dev

	function install_dependency {
		echo "--- Installing dependency: $1"
		sudo apt-get -y install $1
	}

	install_dependency libopencv-dev
	install_dependency build-essential
	install_dependency checkinstall
	install_dependency cmake
	install_dependency pkg-config
	install_dependency yasm
	install_dependency libtiff5-dev
	install_dependency libjpeg-dev
	install_dependency libjasper-dev
	install_dependency libavcodec-dev
	install_dependency libavformat-dev
	install_dependency libswscale-dev
	install_dependency libdc1394-22-dev
	install_dependency libxine2-dev
	install_dependency libgstreamer0.10-dev
	install_dependency libgstreamer-plugins-base0.10-dev
	install_dependency libv4l-dev
	install_dependency python-dev
	install_dependency python-numpy
	install_dependency libtbb-dev
	install_dependency libqt5x11extras5
	install_dependency libqt5opengl5
	install_dependency libqt5opengl5-dev
	install_dependency libgtk2.0-dev
	install_dependency libfaac-dev
	install_dependency libmp3lame-dev
	install_dependency libopencore-amrnb-dev
	install_dependency libopencore-amrwb-dev
	install_dependency libtheora-dev
	install_dependency libvorbis-dev
	install_dependency libxvidcore-dev
	install_dependency x264
	install_dependency v4l-utils
	#install_dependency ffmpeg
	install_dependency unzip

	version="$(wget -q -O - http://sourceforge.net/projects/opencvlibrary/files/opencv-unix | egrep -o '\"[0-9](\.[0-9]+)+(-[-a-zA-Z0-9]+)?' | cut -c2- |sort -V -r -u |head -1)"
	downloadfilelist="opencv-$version.tar.gz opencv-$version.zip"
	downloadfile=
	for file in $downloadfilelist;
	do
			wget --spider http://sourceforge.net/projects/opencvlibrary/files/opencv-unix/$version/$file/download
			if [ $? -eq 0 ]; then
					downloadfile=$file
			fi
	done
	if [ -z "$downloadfile" ]; then
			echo "Could not find download file on sourceforge page.  Please find the download file for version $version at"
			echo "http://sourceforge.net/projects/opencvlibrary/files/opencv-unix/$version/ and update this script"
			exit  1
	fi

	if [[ -z "$version" ]]; then
    echo "Please define version before calling `basename $0` or use a wrapper like opencv_latest.sh"
	fi

	if [[ -z "$downloadfile" ]]; then
		echo "Please define downloadfile before calling `basename $0` or use a wrapper like opencv_latest.sh"
		exit 1
	fi
	if [[ -z "$dldir" ]]; then
		dldir=OpenCV
	fi
	if ! sudo true; then
		echo "You must have root privileges to run this script."
		exit 1
	fi
	set -e

	echo "--- Installing OpenCV" $version

	echo "--- Installing Dependencies"
	source dependencies.sh

	echo "--- Downloading OpenCV" $version
	mkdir -p $dldir
	cd $dldir
	wget -c -O $downloadfile http://sourceforge.net/projects/opencvlibrary/files/opencv-unix/$version/$downloadfile/download

	echo "--- Installing OpenCV" $version
	echo $downloadfile | grep ".zip"
	if [ $? -eq 0 ]; then
		unzip $downloadfile
	else
		tar -xvf $downloadfile
	fi
	cd opencv-$version
	mkdir build
	cd build
	cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local -D WITH_TBB=ON -D BUILD_NEW_PYTHON_SUPPORT=ON -D WITH_V4L=ON -D INSTALL_C_EXAMPLES=ON -D INSTALL_PYTHON_EXAMPLES=ON -D BUILD_EXAMPLES=ON -D WITH_QT=ON -D WITH_OPENGL=ON ..
	make -j$(nproc)
	sudo make install
	sudo sh -c 'echo "/usr/local/lib" > /etc/ld.so.conf.d/opencv.conf'
	sudo ldconfig
	echo "OpenCV" $version "ready to be used"

elif [ $input == "jdk" ] || [ $input == "java" ]; then
	sudo add-apt-repository ppa:webupd8team/java -y

	sudo apt update; sudo apt install -y oracle-java8-installer
	javac -version
	sudo apt install -y oracle-java8-set-default

elif [ $input == "docker" ]; then
        echo "Installing Docker...."

        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

        sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

        sudo apt-get update

        echo "Making sure the Docker is installed from Official Docker repo to get the latest version"
        dockerInstallLoc="$(apt-cache policy docker-ce)"
        echo "${dockerInstallLoc}"

        sudo apt-get install -y docker-ce

        dockerSuccess="$(sudo systemctl status docker)"
        echo "${dockerSuccess}"

        echo "Successfully installed Docker!"

        read -r -p "Do you want to add root privileges to run Docker? [Y/n]" response
        response="${response,,}"

        if [[ $response =~ ^(yes|y| ) ]] || [[ -z $response ]]; then
            echo "Adding your username into Docker group"
            sudo usermod -aG docker ${USER}
            su - ${USER}
            echo "Addition of Username to Docker group is successful!"
        else
            echo "Exited without adding root privileges to run Docker"
        fi

        echo "Docker is ready to be used"

elif [ $input == "mvn" ] || [ $input == "maven" ] ; then
        echo "Installing Maven...."
		sudo add-apt-repository ppa:webupd8team/java -y
		sudo apt update -y
		sudo apt install -y oracle-java8-installer
		cd /opt/
		sudo wget http://www-eu.apache.org/dist/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz
		sudo tar -xvzf apache-maven-3.3.9-bin.tar.gz
		sudo mv apache-maven-3.3.9 maven 
		echo 'export M2_HOME=/opt/maven
				export PATH=${M2_HOME}/bin:${PATH}' | sudo tee /etc/profile.d/mavenenv.sh;
		sudo chmod +x /etc/profile.d/mavenenv.sh
		source /etc/profile.d/mavenenv.sh
		mvn --version
        echo "Maven is ready to be used"

elif [ $input == "hadoop" ]; then
        echo "Installing Hadoop...."
		wget http://www-us.apache.org/dist/hadoop/common/hadoop-2.7.4/hadoop-2.7.4.tar.gz
		wget https://dist.apache.org/repos/dist/release/hadoop/common/hadoop-2.7.3/hadoop-2.7.3.tar.gz.mds
		shasum -a 256 hadoop-2.7.3.tar.gz
		cat hadoop-2.7.3.tar.gz.mds

		echo "Please check for the checksums"

		tar -xzvf hadoop-2.7.4.tar.gz
		sudo mv hadoop-2.7.4 /usr/local/hadoop
		#readlink -f /usr/bin/java | sed "s:bin/java::"
		echo 'export JAVA_HOME=/usr/lib/jvm/java-8-oracle/' | sudo tee -a ~/.bashrc
		echo 'export HADOOP_INSTALL=/usr/local/hadoop' | sudo tee -a ~/.bashrc
		echo 'export PATH=$PATH:$HADOOP_INSTALL/bin' | sudo tee -a ~/.bashrc
		echo 'export PATH=$PATH:$HADOOP_INSTALL/sbin' | sudo tee -a ~/.bashrc
		alias brc='source ~/.bashrc'
		
		echo "Please run 'source ~/.bashrc' if hadoop is not working"

elif [ $input == "vncserver" ]; then
        echo "Installing VNCServer...."
		sudo apt install xfce4 xfce4-goodies tightvncserver
        echo "VNCServer is ready to be used"

elif [ $input == "nvm" ]; then
        echo "Installing NVM [Node Version Manager]...."

        sudo apt-get update

        sudo apt-get install build-essential libssl-dev

        curl https://raw.githubusercontent.com/creationix/nvm/v0.33.6/install.sh | bash

        . ~/.nvm/nvm.sh
        . ~/.profile
        . ~/.bashrc

        nvm --version

        echo "Installing NVM [Node Version Manager] was successful!"

        read -r -p "Please specify the NodeJS version that you want to use - " nodejsversion
        nodejsversion="${nodejsversion}"

        echo "Installing NodeJS version - $nodejsversion"
        nvm install $nodejsversion

        echo "Your NodeJS version has been converted into - $nodejsversion"
        echo "Run 'nvm ls' to see NodeJS version installed!"
        echo "Run 'nvm use {nodejsverison}' to run a specified NodeJS version from the NodeJS installed list"

elif [ $input == "mongodb" ]; then
	echo "Installing MongoDB...."
	sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2930ADAE8CAF5059EE73BB4B58712A2291FA4AD5
	echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.6 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.6.list
	sudo apt-get update
	sudo apt-get install -y mongodb-org
	echo "Starting Mongodb Service..."
	sudo service mongod start
	echo "Service started (Hopefully)..."
	echo "Run 'mongo' to connect to the local server which is running on 27017"

elif [ $input == "phpmyadmin" ]; then
	echo "Inastalling phpmyadmin..."
	sudo apt-get update
	sudo apt-get install phpmyadmin php-mbstring php-gettext
	sudo phpenmod mcrypt
	sudo phpenmod mbstring
	sudo systemctl restart apache2
	
else 
	echo "Nothing was installed!"
	echo "Bye!"
fi

