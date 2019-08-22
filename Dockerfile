# Get PHP v7.2 with Apache Server
FROM php:7.2-apache

# Update & install curl
RUN apt-get update && apt-get -y install curl

# Enable mod_rewrite
RUN a2enmod rewrite

# Install php packages
RUN pecl install xdebug

# Enable php packages
RUN docker-php-ext-enable xdebug

# Copy source
# COPY . /var/www/html/
