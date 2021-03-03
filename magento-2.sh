#!/bin/bash

public_key=''       #Enter Magento User Public Key
private_key=''      #Enter Magento User Private Key

sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
sudo echo "/swapfile   none    swap    sw    0   0" >> /etc/fstab
sudo sysctl vm.swappiness=10

sudo apt update
sudo apt update
sudo apt install apache2 -y
sudo systemctl start apache2
sudo systemctl enable apache2
sudo a2enmod rewrite
sudo apt install mysql-client -y

sudo apt-get install software-properties-common -y
sudo add-apt-repository ppa:ondrej/php -y

sudo apt install -y php7.4 libapache2-mod-php7.4 php7.4-common php7.4-gmp php7.4-curl php7.4-soap php7.4-bcmath php7.4-intl php7.4-mbstring php7.4-xmlrpc php7.4-mysql php7.4-gd php7.4-xml php7.4-cli php7.4-zip
sudo sed -i 's/memory_limit = 128M/memory_limit = 256M/g' /etc/php/7.4/apache2/php.ini
sudo sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 100M/g' /etc/php/7.4/apache2/php.ini
sudo sed -i 's/max_execution_time = 30/max_execution_time = 360/g' /etc/php/7.4/apache2/php.ini
sudo systemctl restart apache2

sudo wget https://getcomposer.org/download/1.10.20/composer.phar
sudo mv composer.phar /usr/local/bin/composer
sudo chmod +x /usr/local/bin/composer

sudo mkdir /home/magento
sudo useradd -d /home/magento -s /bin/bash magento
sudo chown -R magento:magento /home/magento
sudo sed -i 's/www-data/magento/g' /etc/apache2/envvars
sudo mkdir /home/magento/public_html
sudo mkdir /home/ubuntu/.composer
sudo echo '{"http-basic": {"repo.magento.com": {"username": "'$public_html'","password": "'$private_key"}}}' >> /home/ubuntu/.composer/auth.json
sudo composer create-project -n --repository=https://repo.magento.com/ magento/project-community-edition /home/magento/public_html/magento
sudo chown -R magento:magento /home/magento
sudo chmod -R 755 /home/magento/public_html/magento

sudo wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.6.2-amd64.deb
sudo apt-get install apt-transport-https -y
sudo dpkg -i elasticsearch-7.6.2-amd64.deb
sudo update-rc.d elasticsearch defaults 95 10
sudo service elasticsearch restart

sudo cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/000-default.conf.bak
sudo sed -i 's*DocumentRoot /var/www/html*DocumentRoot /home/magento/public_html/magento*g' /etc/apache2/sites-available/000-default.conf
sudo sed -i 's*<Directory /var/www/>*<Directory /home/magento/public_html/magento>*g' /etc/apache2/apache2.conf
sudo sed -i 's/AllowOverride None/AllowOverride All/g' /etc/apache2/apache2.conf
sudo systemctl restart apache2

sudo rm /home/ubuntu/magento-2.sh
