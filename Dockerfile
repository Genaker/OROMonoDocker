# Use the official Ubuntu 24.04 LTS as the base image
FROM ubuntu:24.04 as core
#docker run -it --rm ubuntu:22.04 bash

# Set environment variables to avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install PHP 8.3 with all required extensions:
# Install gnupg for handling GPG keys
RUN apt update
RUN apt install -y sudo curl nano wget htop net-tools

RUN apt install software-properties-common -y && \
    add-apt-repository -y ppa:ondrej/php && \
    apt update && \
    apt -y install php8.3 php8.3-fpm php8.3-cli php8.3-pdo php8.3-mysqlnd php8.3-xml php8.3-soap php8.3-gd php8.3-zip php8.3-intl php8.3-mbstring php8.3-opcache php8.3-curl php8.3-bcmath php8.3-ldap php8.3-pgsql php8.3-dev php8.3-mongodb && \
    echo -e "memory_limit = 2048M \nmax_input_time = 600 \nmax_execution_time = 600 \nrealpath_cache_size=4096K \nrealpath_cache_ttl=600 \nopcache.enable=1 \nopcache.enable_cli=0 \nopcache.memory_consumption=512 \nopcache.interned_strings_buffer=32 \nopcache.max_accelerated_files=32531 \nopcache.save_comments=1" | tee -a  /etc/php/8.3/fpm/php.ini && \
    echo -e "memory_limit = 2048M" | tee -a  /etc/php/8.3/cli/php.ini && \
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');" && \
    mv composer.phar /usr/bin/composer && \
    apt-get clean
# sudo service php8.3-fpm start

RUN apt -y install curl dirmngr apt-transport-https lsb-release ca-certificates && \
    curl -sL https://deb.nodesource.com/setup_20.x | bash - && \
    apt -y install nodejs && \
    apt-get clean

# Update the package list and install Nginx
RUN apt-get update && \
    apt-get install -y nginx && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /var/www/html/oro/ 
RUN cat << 'EOF' > /etc/nginx/conf.d/default.conf
server {
server_name localhost www.localhost;
root /var/www/html/oro/public;

location / {
try_files $uri /index.php$is_args$args;
}

location ~ ^/(index|index_dev|config|install)\.php(/|$) {
#fastcgi_pass 127.0.0.1:9000;
fastcgi_pass unix:/run/php/php8.3-fpm.sock;
fastcgi_split_path_info ^(.+\.php)(/.*)$;
include fastcgi_params;
fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
fastcgi_param HTTPS off;
}

location ~* ^[^(\.php)]+\.(jpg|jpeg|gif|png|ico|css|pdf|ppt|txt|bmp|rtf|js)$ {
access_log off;
expires 1h;
add_header Cache-Control public;
}

error_log /var/log/nginx/localhost_error.log;
access_log /var/log/nginx/localhost_access.log;
}
EOF
#service nginx start

# PostgreSQL install
RUN apt-get update && apt install -y postgresql postgresql-contrib &&  \
    service postgresql start && \
    su - postgres -c "psql -c 'CREATE DATABASE oro;'" && \
    su - postgres -c "psql -c \"ALTER USER postgres WITH PASSWORD 'postgres';\"" && \
    export PGPASSWORD='postgres' && \
    service postgresql restart && \
    psql -h localhost -U postgres -c '\l' && \
    psql -h localhost -U postgres -d oro -c 'CREATE EXTENSION IF NOT EXISTS "uuid-ossp";' && \
    apt-get clean
# service postgresql start

RUN apt install redis-server -y
# service redis-server start

# Copy a custom Nginx configuration file if needed
# COPY nginx.conf /etc/nginx/nginx.conf

RUN mkdir -p /var/www/html/oro && cd /var/www/html/oro/ && \
    composer create-project oro/commerce-crm-application /var/www/html/oro 6.0.3 -n && \
    ln -s /var/www/html/oro/bin/console /usr/local/bin/symfony && chmod 755 /usr/local/bin/symfony && \
    export POSTGRES_USER=postgres && \
    export POSTGRES_PASSWORD=postgres && \
    export POSTGRES_DB=oro && \
    export ORO_DB_DRIVER=pdo_pgsql && \
    export ORO_DB_HOST=localhost && \
    export ORO_DB_PORT=5432 && \
    export ORO_DB_USER=postgres && \
    export ORO_DB_PASSWORD=postgres && \
    export ORO_DB_NAME=oro && \
    RO_DB_URL=postgres://postgres:postgres@127.0.0.1:5432/oro?sslmode=disable&charset=utf8&serverVersion=13.7 && \
    php bin/console oro:install --env=prod --timeout=2000 && \
    php bin/console oro:migration:data:load --fixtures-type=demo --env=prod && \
    php bin/console oro:assets:install --symlink && \
    php bin/console oro:search:reindex && \
    sudo chmod -R 777 .

# Expose port 80 to allow external access
EXPOSE 80

# php bin/console oro:message-queue:consume --memory-limit 500000 

# sudo service php8.3-fpm start && service nginx start && service postgresql start && service redis-server start  
# Start Nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]
