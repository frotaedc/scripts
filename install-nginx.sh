sudo apt update
sudo apt install -y nginx

#configurando o firewall para permitir o ngnix

sudo ufw app list
sudo ufw allow 'Nginx HTTP'
sudo ufw status

systemctl status nginx

systemctl start, disable, enable, stop nginx

ip addr show


https://www.youtube.com/watch?v=NK2idGU8Cq8
------------------------------------------------------------------------------

# Você vai precisar de acesso ao shell do seu servidor, de um usuário que tenha
# acesso sudo (escrevi um tutorial sobre isso aqui) para atualizar,
# instalar e configurar pacotes, e estar conectado à internet para baixar os
# pacotes que serão utilizados nesse tutorial.
#
# Verifique também como está o arquivo /etc/apt/sources.list do seu Debian:
#
sudo nano /etc/apt/sources.list
#
# Dados do arquivo:
#
###### Debian Main Repos
deb http://deb.debian.org/debian/ stable main contrib non-free
deb-src http://deb.debian.org/debian/ stable main contrib non-free
#
deb http://deb.debian.org/debian/ stable-updates main contrib non-free
deb-src http://deb.debian.org/debian/ stable-updates main contrib non-free
#
deb http://deb.debian.org/debian-security stable/updates main
deb-src http://deb.debian.org/debian-security stable/updates main
#
deb http://ftp.debian.org/debian stretch-backports main
deb-src http://ftp.debian.org/debian stretch-backports main
#
# Depois, atualize os pacotes digitando:
#
# sudo apt-get update
#
# Instalando o nginx
# Instalar o nginx é tão difícil quanto digitar:
#
sudo apt-get install nginx
#
# No terminal e pressionar “Enter” rsrs.
#
# A versão do nginx no momento da criação desse tutorial é:
#
# nginx version: nginx/1.10.3
#
# Instalando o PHP 7.2
#
# Para instalar o PHP 7, você precisa adicionar repositórios na sua versão de
# sistema operacional.
#
# Para Ubuntu:
#
sudo apt-get install software-properties-common
sudo add-apt-repository ppa:ondrej/php
sudo apt-get update
#
# Para Debian:
#
sudo apt-get install ca-certificates apt-transport-https
wget -q https://packages.sury.org/php/apt.gpg -O- | sudo apt-key add -
echo "deb https://packages.sury.org/php/ stretch main" | sudo tee /etc/apt/sources.list.d/php.list
sudo apt-get update
#
# Para instalar o PHP 7.2 e mais alguns recursos do PHP 7 tanto no Ubuntu como
# no Debian, digite:
#
sudo apt-get install php7.2-fpm php7.2-common php7.2-mbstring php7.2-xmlrpc php7.2-soap php7.2-gd php7.2-xml php7.2-intl php7.2-mysql php7.2-cli php7.2-zip php7.2-curl
#
# Prontinho, mas agora vamos editar o arquivo php.ini.
#
# No php-fpm, este arquivo está em /etc/php/7.2/fpm/php.ini. Então digite o
# seguinte para editá-lo:
#
sudo nano /etc/php/7.2/fpm/php.ini
#
# Altere o seguinte:
#
# ...
# file_uploads = On
# ...
# allow_url_fopen = On
# ...
# memory_limit = 256M
# ...
# upload_max_filesize = 100M
# ...
# max_execution_time = 360
# ...
# date.timezone = America/Sao_Paulo
# ...
#
# E salve o arquivo.
#
# Pool do site no php-fpm
#
# O php-fpm trabalha com uma “pool” por site, ou seja, cada site terá um arquivo
# de configuração com dados específicos, como: nome do site, usuário e grupo,
# configurações de desempenho e muito mais.
#
# Já existe um arquivo padrão de pool chamado de www.conf em
# /etc/php/7.2/fpm/pool.d/. Para cada site configurado no seu servidor, você
# precisará gerar um novo arquivo desse.
#
# Digite o seguinte no seu terminal para copiar esse arquivo para outro chamado
# de pool_do_site.conf (você pode dar um nome que preferir para este arquivo,
# mas mantenha a extensão .conf).
#
sudo cp /etc/php/7.2/fpm/pool.d/www.conf /etc/php/7.2/fpm/pool.d/pool_do_site.conf
#
Vamos alterar esse arquivo, então digite:
#
sudo nano /etc/php/7.2/fpm/pool.d/pool_do_site.conf
#
# Altere o seguinte:
#
# ...
# [www] <- Altere para -> [pool_do_site]
# ...
# user = www-data <- Altere para -> usuario_do_site
# group = www-data <- Altere para -> usuario_do_site
# ...
# listen = /run/php/php7.2-fpm.sock <- Altere para -> 127.0.0.1:9010
# ...
# Como na imagem a seguir:
#
# Editando a pool do site
#
# Para cada site você precisa de valores diferentes para:
#
# [www] – Um nome por pool por site;
# user – Um usuário por site;
# group – Um grupo por site;
# listen – Uma porta por site. Nesse caso estou usando 9010, os próximos seriam
# 9011, 9012, e assim por diante.
# Agora vamos criar um server block no nginx (um virtualhost pra quem conhece
# o apache).
#
# Criando um server block no nginx (virtualhost)
# Para cada site é necessário um server block diferente, este é o arquivo de
# configuração do site para o nginx.
#
# Existem dois locais onde esses arquivos residem:
#
# /etc/nginx/sites-enabled/
# /etc/nginx/sites-available/
#
# Em sites-enabled estão todos os sites ativos e funcionando; em sites-available
# estão os sites configurados, mas não ativos. Em ambas as pastas existe um
# arquivo de configuração padrão chamado default.
#
# Para criar o server block do seu site, digite:
#
sudo nano /etc/nginx/sites-enabled/meusite.com.br
#
# Você pode adicionar o nome que preferir nesse arquivo, mas é preferível
# colocar o domínio do site (conforme o exemplo acima).
#
# Adicione o seguinte nesse arquivo:
#
server {
	listen 80;
	listen [::]:80;

	# Caminho da pasta do site
	root /var/www/pasta_do_site/;
	index index.html index.htm index.nginx-debian.html index.php;

	# Para produção use o nome do seu domínio. Ex.:
	# server_name meusite.com.br www.meusite.com.br;
	server_name localhost;

	location / {
		try_files $uri $uri/ =404;

		# Para WordPress utilize:
		# try_files $uri $uri/ /index.php?q=$uri&$args;
	}

	# Envia scripts PHP para o FastCGI (php-fpm)
	location ~ \.php$ {
		include snippets/fastcgi-php.conf;

		if (!-f $realpath_root$fastcgi_script_name) {
			return 404;
		}

		fastcgi_buffers 16 16k;
		fastcgi_buffer_size 32k;

		include /etc/nginx/fastcgi_params;

		# Aqui você deve adicionar o mesmo endereço da configuração
		# listen da pool do seu site
		fastcgi_pass 127.0.0.1:9010;

		# Se preferir, pode criar um log de acesso específico para o php-fpm
		# access_log /var/log/nginx/meusite.com.br-php-fpm-access.log;
		access_log off;
	}

	# Bloqueia acesso aos arquivos ocultos
	location ~ /\. {
		access_log off;
		log_not_found off;
		deny all;
	}

	# Log de acessos e log de erros
	access_log  /var/log/nginx/meusite.com.br-access.log;
	error_log   /var/log/nginx/meusite.com.br-error.log;
}
#
# Detalhei as partes importantes do código em comentários que começam com “#”
# (o servidor não lê essas linhas).
#
# Agora precisamos criar a pasta e usuário do nosso site, vamos lá então.
#
# Criando a pasta e usuário do site
# Digite o seguinte para criar uma pasta:
#
# Cria uma pasta para o site
sudo mkdir --mode=755 /var/www/pasta_do_site/
#
Digite o seguinte para criar um usuário:
#
# Cria o usuário do site
sudo useradd usuario_do_site -d /var/www/pasta_do_site/ -s /sbin/nologin
#
# Altere a senha digitando:
#
# Altera a senha do usuário do site
sudo passwd usuario_do_site
#
# Agora modifique as permissões da pasta do site digitando:
#
# Dá permissões do usuário do site na pasta do site
sudo chown -R usuario_do_site:usuario_do_site /var/www/pasta_do_site/
#
# Em todos os comando acima, altere pasta_do_site e usuario_do_site para os
# dados que preferir.
#
# Nosso primeiro arquivo .php
# Para criar o seu primeiro arquivo PHP, digite o seguinte:
#
sudo printf "<?php\nphpinfo();\n?>" | sudo tee /var/www/pasta_do_site/index.php
#
# Acima estou apenas criando um arquivo chamado index.php com os dados a seguir:
#
<?php
phpinfo();
?>
#
# Talvez seja necessário alterar a permissão desse arquivo para o usuário do
# site, então digite:
#
sudo chown usuario_do_site:usuario_do_site /var/www/pasta_do_site/index.php
#
# Altere “usuario_do_site” para o nome de usuário que escolheu.
#
# Reiniciando e testando
# Agora que já fizemos toda a configuração, digite o seguinte para reiniciar o
# nginx e o php-fpm:
#
sudo systemctl restart php7.2-fpm && sudo systemctl restart nginx
#
# Então você pode abrir o seu domínio no navegador de Internet e verá o seguinte:
#
# Dados do nosso index.php
#
# Pronto!
#
# Configurando um servidor FTP
# Para que você não tenha que ficar alterando as permissões dos arquivos toda
# vez que criar um novo arquivo na pasta do seu site, você pode enviar os dados
# por FTP. Vamos instalar e configurar um servidor FTP básico.
#
sudo apt-get install proftpd
#
# Agora vamos editar as configurações do servidor FTP. Para isso digite:
#
sudo nano /etc/proftpd/proftpd.conf
#
# E edite as seguintes linhas:
#
# ...
# # Adicione o nome do seu servidor
# ServerName                      "Nome do seu servidor"
# ...
# # Descomente a linha
# DefaultRoot                     ~
# ...
# # Descomente a linha
# RequireValidShell               off
# ...
# Agora reinicie o servidor FTP:
#
sudo systemctl restart proftpd
#
# Agora você pode usar o Filezilla (por exemplo) para enviar arquivos pro seu
# site usando o usuário do site que criamos anteriormente.