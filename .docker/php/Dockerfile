ARG PHP_VERSION=8.0
FROM php:${PHP_VERSION}-fpm AS php
ARG XDEBUG_VERSION=3.1.4


# Set user and group
ARG UID=1000
ARG GID=1000
RUN usermod --uid ${UID} www-data && \
    groupmod --gid ${GID} www-data

ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN chmod +x /usr/local/bin/install-php-extensions

# Install packages
#RUN echo 'deb [trusted=yes] https://repo.symfony.com/apt/ /' | tee /etc/apt/sources.list.d/symfony-cli.list
RUN curl -1sLf 'https://dl.cloudsmith.io/public/symfony/stable/setup.deb.sh' | bash

RUN apt-get update && apt-get install -y \
    wget \
    git \
    unzip \
    libicu-dev \
    libzip-dev \
    libpq-dev \
    gosu \
    symfony-cli \
    libmagickwand-dev \
    && docker-php-ext-configure intl \
    && install-php-extensions \
        intl \
        exif \
        pdo \
        pgsql \
        pdo_pgsql \
        opcache \
        mysqli \
        pdo_mysql \
        zip \
        imagick
RUN pecl install xdebug-${XDEBUG_VERSION}
## Install composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY ini/symfony.ini /usr/local/etc/php/conf.d/99-symfony.ini
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
CMD ["php-fpm"]
