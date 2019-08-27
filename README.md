# Savannah
PHP Integrated Development Environment Container for Docker 🐘🐳🌱

## Getting started

Pull Savannah Docker Image from Docker Hub.

```bash
$ docker pull stcandre/savannah
```

Run Savannah Image.

```bash
$ docker run -it -p 80:80 -v /path/to/sites:/var/www/html --name phpide stcandre/savannah
```

Go to <http://localhost>.

## Infrastructure

### Platform & Webserver

- Ubuntu 18.04
- Apache 2.4
- PHP 7.2

### PHP Extensions

Following php extensions located in `/usr/lib/php/20170718/`.

- bcmath
- bz2
- calendar
- Core
- ctype
- curl
- date
- dom
- exif
- fileinfo
- filter
- ftp
- gd
- gettext
- hash
- iconv
- json
- libxml
- mbstring
- openssl
- pcntl
- pcre
- PDO
- pdo_sqlite
- pdo_sqlsrv
- Phar
- posix
- readline
- Reflection
- session
- shmop
- SimpleXML
- sockets
- sodium
- SPL
- sqlite3
- sqlsrv
- standard
- sysvmsg
- sysvsem
- sysvshm
- tokenizer
- wddx
- xdebug
- xml
- xmlreader
- xmlwriter
- xsl
- Zend OPcache
- zip
- zlib

### Webserver Root Directory

`/var/www/html/`

### PHP ini Files

- Apache: `/etc/php/7.2/apache2/php.ini`
- CLI: `/etc/php/7.2/cli/php.ini`
- PHP modules `.ini` files: `/etc/php/7.2/mods-available/`
