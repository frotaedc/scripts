sudo chmod 755 -R /var/www/
sudo chown www-data:www-data -R /var/www/
sudo chown $USER -R /var/www/

sudo apt install -y apache2 apache2-utils
sudo apt install -y ssl-cert

sudo /etc/init.d/apache2 status start stop restart reload(recarrega arquivos de config sem restartar)


