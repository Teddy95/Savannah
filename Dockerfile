# Starting from Ubuntu
FROM ubuntu:18.04
ENV DEBIAN_FRONTEND=noninteractive

# Maintainer
LABEL maintainer="Andre Sieverding"

# Install Utils
RUN apt-get update && apt-get install -y apt-utils

# Install PHP
RUN apt-get update && TZ=Europe/Berlin apt-get -y install \
	php7.2 \
	php-mbstring \
	php-pear \
	php7.2-dev \
	php7.2-xml \
	php7.2-bcmath \
	php7.2-bz2 \
	php7.2-curl \
	php7.2-gd \
	php7.2-sqlite \
	php7.2-zip

# Install Apache
RUN apt-get update && apt-get install -y apache2
RUN apt-get update && apt-get install -y libapache2-mod-php7.2

# Install pre-requisites for Microsoft SQL Server
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
	&& curl https://packages.microsoft.com/config/ubuntu/18.04/prod.list > /etc/apt/sources.list.d/mssql-release.list
RUN apt-get update && ACCEPT_EULA=Y apt-get -y install msodbcsql17
RUN apt-get update && ACCEPT_EULA=Y apt-get -y install mssql-tools
# RUN apt-get update && apt-get install -y unixodbc unixodbc-dev
RUN apt-get update && apt-get install -y unixodbc-dev

# Install Microsoft SQL Server Drivers for PHP
RUN pecl install sqlsrv
RUN pecl install pdo_sqlsrv

# Install XDebug
RUN pecl install xdebug

# Add PHP Extensions to php.ini files
RUN echo "extension=/usr/lib/php/20170718/sqlsrv.so" >> /etc/php/7.2/apache2/php.ini \
	&& echo "extension=/usr/lib/php/20170718/pdo_sqlsrv.so" >> /etc/php/7.2/mods-available/pdo.ini \
	&& echo "extension=/usr/lib/php/20170718/sqlsrv.so" >> /etc/php/7.2/cli/php.ini \
# 	&& echo "extension=/usr/lib/php/20170718/pdo_sqlsrv" >> /etc/php/7.2/cli/php.ini \
	&& echo "zend_extension=/usr/lib/php/20170718/xdebug.so" >> /etc/php/7.2/apache2/php.ini \
	&& echo "zend_extension=/usr/lib/php/20170718/xdebug.so" >> /etc/php/7.2/cli/php.ini

# Clear directory /var/www/html/
RUN rm -rf /var/www/html/*

# Copy source
# COPY . /var/www/html/

# Enable mod_rewrite Apache Module
RUN a2enmod rewrite

# Copy virtual host config file for Apache
COPY apache/vhosts.conf /etc/apache2/sites-available/000-default.conf

# Copy XDebug Configurations
COPY apache/xdebug.ini /etc/php/7.2/mods-available/xdebug.ini

# Make www-data owner of all web contents
RUN chown -R www-data:www-data /var/www/html/

# Start Apache
RUN service apache2 restart

# Set Apache ENVs
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2

# Expose Server Port
EXPOSE 80

# Show Apache Output
CMD ["apachectl", "-D", "FOREGROUND"]
