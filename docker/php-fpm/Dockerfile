# See https://github.com/docker-library/php/blob/master/7.1/fpm/Dockerfile
FROM php:7.2-fpm

RUN apt-get update && apt-get install -y \
    openssl \
    git \
    unzip

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN composer --version

RUN mkdir /.composer
RUN chmod 775 /.composer

# Set timezone
RUN ln -snf /usr/share/zoneinfo/Europe/Paris /etc/localtime && echo Europe/Paris > /etc/timezone
RUN printf '[PHP]\ndate.timezone = "%s"\n', Europe/Paris > /usr/local/etc/php/conf.d/tzone.ini
RUN "date"

# Type docker-php-ext-install to see available extensions
RUN docker-php-ext-install pdo pdo_mysql

RUN pecl install xdebug-2.6.0
RUN docker-php-ext-enable xdebug

WORKDIR /var/www
