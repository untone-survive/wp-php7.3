FROM php:7.3-fpm

# Install dependencies
RUN apt-get update && apt-get -y --no-install-recommends install \
    libpng-dev \
    libjpeg-dev \
    libzip-dev \
    zip \
    unzip \
    curl

# Install extensions
RUN docker-php-ext-configure gd --with-gd --with-png-dir=/usr/include/ --with-jpeg-dir=/usr/include/
# --with-freetype-dir=/usr/include/
RUN docker-php-ext-install gd
RUN docker-php-ext-install zip
RUN docker-php-ext-install mysqli
RUN docker-php-ext-install mbstring
RUN docker-php-ext-install opcache


# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=2'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini


# Install xDebug module
# to disable it use this commands in your Dockerfile when extending:
# USER root;
# RUN rm /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
# USER www-data;

RUN pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && echo "error_reporting = E_ALL" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "display_startup_errors = On" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "display_errors = On" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.mode=debug" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.idekey=docker" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini;


# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Use the default development configuration
RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"
RUN chown www-data:www-data /var/www/html

# fix user rights for files
USER www-data
# Set working directory
WORKDIR /var/www/html
