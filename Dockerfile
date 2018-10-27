FROM php:7.2-fpm-alpine

RUN echo 'http://dl-cdn.alpinelinux.org/alpine/v3.5/main/' >> /etc/apk/repositories \
    && echo 'http://dl-cdn.alpinelinux.org/alpine/v3.5/community/' >> /etc/apk/repositories

RUN apk add --no-cache --virtual .build-deps $PHPIZE_DEPS

RUN apk --no-cache --update add \
    shadow \
    git \
    pcre-dev \
    postgresql-dev \
    freetype-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    autoconf icu-dev gettext-dev gcc g++ libtool make \
    imagemagick-dev \
    libxml2-dev \
    openssh \
    mysql-client

# Install Opcache Extension
RUN docker-php-ext-configure opcache --enable-opcache \
    && docker-php-ext-install opcache

# Install MySQL PDO Extension
RUN docker-php-ext-install pdo_mysql

# Install Postgres PDO Extension
RUN docker-php-ext-install pdo_pgsql

# Install bcmath extension
RUN docker-php-ext-install bcmath

# Install Zip Extension
RUN docker-php-ext-install zip

# Install intl Extension
RUN docker-php-ext-install intl
RUN docker-php-ext-install gettext

# Install GD extension
RUN docker-php-ext-install exif \
  && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
  && docker-php-ext-install -j$(getconf _NPROCESSORS_ONLN) gd

# install imagick
RUN pecl install imagick
RUN docker-php-ext-enable imagick

# install xmlrpc extension
RUN docker-php-ext-install xmlrpc

# Install mongodb extension
RUN pecl install mongodb && \
    docker-php-ext-enable mongodb

# Install Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php composer-setup.php
RUN php -r "unlink('composer-setup.php');"
RUN mv composer.phar /usr/local/bin/composer

# Cleanup
RUN apk del --purge .build-deps \
    && apk del --purge autoconf g++ libtool make pcre-dev \
    && rm -rf /var/cache/apk/*

RUN mkdir -p /home/www-data/.ssh
COPY ./ssh/config /home/www-data/.ssh/config

RUN usermod -u 1000 www-data

