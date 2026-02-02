#!/bin/bash
# Update package lists
sudo apt-get update

# Install Apache
sudo apt-get install apache2 -y
sudo systemctl start apache2
sudo systemctl enable apache2

# Install PHP and required extensions
sudo apt-get install php php-cli php-common php-mysql php-readline php-curl php-xml php-zip php-intl php-gd php-ldap -y

# Install MariaDB
sudo apt-get install mariadb-server -y
sudo systemctl start mariadb
sudo systemctl enable mariadb

# Secure MariaDB installation
sudo mysql -e "UPDATE mysql.user SET Password = PASSWORD('your_root_password') WHERE User = 'root';"
sudo mysql -e "DELETE FROM mysql.user WHERE User='';"
sudo mysql -e "DROP DATABASE IF EXISTS test;"
sudo mysql -e "FLUSH PRIVILEGES;"

# Create OrangeHRM database and user
sudo mysql -u root -p'your_root_password' -e "CREATE DATABASE orangehrm_db;"
sudo mysql -u root -p'your_root_password' -e "CREATE USER 'orangehrm'@'localhost' IDENTIFIED BY 'Muruga@1';"
sudo mysql -u root -p'your_root_password' -e "GRANT ALL PRIVILEGES ON orangehrm_db.* TO 'orangehrm'@'localhost';"
sudo mysql -u root -p'your_root_password' -e "FLUSH PRIVILEGES;"

# Download and install OrangeHRM
wget https://sourceforge.net/projects/orangehrm/files/stable/5.7/orangehrm-5.7.zip/download -O orangehrm-5.7.zip
sudo apt-get install unzip -y
unzip orangehrm-5.7.zip
sudo mv orangehrm-5.7 /var/www/html/orangehrm
sudo chown -R www-data:www-data /var/www/html/orangehrm/
sudo chmod -R 755 /var/www/html/orangehrm/

# Configure Apache for OrangeHRM
sudo bash -c 'cat <<EOT > /etc/apache2/sites-available/orangehrm.conf
<VirtualHost *:80>
    ServerAdmin admin@yourdomain.com
    DocumentRoot /var/www/html/orangehrm
    <Directory /var/www/html/orangehrm>
        Options -Indexes +FollowSymLinks +MultiViews
        AllowOverride All
        Require all granted
    </Directory>
    ErrorLog \${APACHE_LOG_DIR}/orangehrm-error.log
    CustomLog \${APACHE_LOG_DIR}/orangehrm-access.log combined
</VirtualHost>
EOT'

sudo a2dissite 000-default.conf
sudo a2ensite orangehrm.conf
sudo systemctl reload apache2

# Configure UFW firewall


# Restart Apache to apply changes
sudo systemctl restart apache2



#data store location
##Please backup encryption key located at lib/confs/cryptokeys/key.ohrm
