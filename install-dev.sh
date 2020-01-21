#!/usr/bin/env bash
#!/bin/bash

echo Atualizando repositórios..
if ! apt-get update
then
    echo "Não foi possível atualizar os repositórios. Verifique seu arquivo /etc/apt/sources.list"
    exit 1
fi
echo "Atualização feita com sucesso"

echo "Atualizando pacotes já instalados"
if ! apt-get dist-upgrade -y
then
    echo "Não foi possível atualizar pacotes."
    exit 1
fi
echo "Atualização de pacotes feita com sucesso"

# note que $1 aqui será substituído pelo Bash pelo primeiro argumento passado em linha de comando
# Instalando o APACHE, o PHP e suas extenções
sudo apt install -y \
    software-properties-common \
    apache2

sudo add-apt-repository ppa:ondrej/php -y
sudo apt-cache pkgnames | grep php7.2
sudo apt install -y tzdata curl supervisor git unzip libpq-dev nano php \
    php-bcmath php-bz2 php-intl php-gd php-mbstring php-mysql php-zip php-fpm php-xml \
    git

# Instalando o nodejs e o npm, Using Ubuntu
sudo curl -sL https://deb.nodesource.com/setup_13.x | sudo -E bash -
sudo apt-get install -y nodejs

# Using Debian, as root
sudo curl -sL https://deb.nodesource.com/setup_13.x | bash -
sudo apt-get install -y nodejs

# Instalando o Composer e o Laravel
sudo curl -sS https://getcomposer.org/installer -o composer-setup.php
sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer
sudo composer global require laravel/installer

echo "Instalação finalizada"