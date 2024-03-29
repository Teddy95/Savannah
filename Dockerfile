# Starting from Ubuntu
FROM ubuntu:18.04
ENV DEBIAN_FRONTEND=noninteractive

# Maintainer
LABEL maintainer="Andre Sieverding"

# Install Utils
RUN apt-get update && apt-get install -y apt-utils memcached libmcrypt-dev

# Install PHP
RUN apt-get update && apt-get -y install \
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
	php7.2-mysql \
	php7.2-imap \
	php7.2-zip \
	php-memcached \
	php7.2-ldap

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

# Update PECL
RUN pecl channel-update pecl.php.net

# Install Microsoft SQL Server Drivers for PHP
RUN pecl install sqlsrv
RUN pecl install pdo_sqlsrv

# Install MCrypt
# RUN pecl install mcrypt-1.0.2

# Install XDebug
RUN pecl install xdebug

# Add PHP Extensions to php.ini files
RUN echo "extension=/usr/lib/php/20170718/sqlsrv.so" >> /etc/php/7.2/apache2/php.ini \
	&& echo "extension=/usr/lib/php/20170718/pdo_sqlsrv.so" >> /etc/php/7.2/mods-available/pdo.ini \
	&& echo "extension=/usr/lib/php/20170718/sqlsrv.so" >> /etc/php/7.2/cli/php.ini \
	# && echo "zend_extension=/usr/lib/php/20170718/mcrypt.so" >> /etc/php/7.2/apache2/php.ini \
	# && echo "zend_extension=/usr/lib/php/20170718/mcrypt.so" >> /etc/php/7.2/cli/php.ini \
	&& echo "zend_extension=/usr/lib/php/20170718/xdebug.so" >> /etc/php/7.2/apache2/php.ini \
	&& echo "zend_extension=/usr/lib/php/20170718/xdebug.so" >> /etc/php/7.2/cli/php.ini

# Install Composer
RUN curl -o /tmp/composer-setup.php https://getcomposer.org/installer \
	&& curl -o /tmp/composer-setup.sig https://composer.github.io/installer.sig \
	# Make sure we're installing what we think we're installing!
	&& php -r "if (hash('SHA384', file_get_contents('/tmp/composer-setup.php')) !== trim(file_get_contents('/tmp/composer-setup.sig'))) { unlink('/tmp/composer-setup.php'); echo 'Invalid installer' . PHP_EOL; exit(1); }" \
	&& php /tmp/composer-setup.php --no-ansi --install-dir=/usr/local/bin --filename=composer --snapshot \
	&& rm -f /tmp/composer-setup.*

# Clear directory /var/www/html/
RUN rm -rf /var/www/html/*

# Copy source
COPY /www/ /var/www/html/

# Copy virtual host config file for Apache
COPY docker/apache2/000-default.conf /etc/apache2/sites-available/000-default.conf
COPY docker/apache2/default-ssl.conf /etc/apache2/sites-available/default-ssl.conf
COPY docker/apache2/ssl-params.conf /etc/apache2/conf-available/ssl-params.conf

# Copy XDebug Configurations
COPY docker/php/xdebug.ini /etc/php/7.2/mods-available/xdebug.ini

# Make www-data owner of all web contents
RUN chown -R www-data:www-data /var/www/html/

# Set Apache ENVs
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2

# Change Workdirectory
WORKDIR /var/www/html/

# Install Composer Dependencies
RUN composer install

# Generate certificates for ssl
RUN openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -subj \
    "/C=US/ST=California/L=Los Angeles/O=Paradise Engineering/CN=localhost" \
    -keyout /etc/ssl/private/apache.key -out /etc/ssl/certs/apache.crt

# Enable Apache Modules
RUN a2enmod rewrite
RUN a2enmod ssl

# Enable Apache virtual hosts (ssl)
RUN a2ensite default-ssl

# Enable Apache ssl configs
RUN a2enconf ssl-params

# Start Apache
RUN service apache2 restart

# Expose Server Port
EXPOSE 80
EXPOSE 443

# Show Apache Output
CMD ["apachectl", "-D", "FOREGROUND"]
