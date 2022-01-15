FROM php:8.1.1-fpm AS php

# Set user and group
ARG UID=1000
ARG GID=1000

RUN usermod --uid ${UID} www-data && \
    groupmod --gid ${GID} www-data

# Install packages
RUN apt-get update && apt-get install -y \
    wget \
    git \
    unzip \
    libicu-dev \
    libzip-dev \
    libpq-dev \
    gosu \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-configure intl \
    && docker-php-ext-install intl \
    && docker-php-ext-install exif \
    && docker-php-ext-install -j$(nproc) gd

# Install PHP extensions
RUN pecl install xdebug-3.1.2

RUN docker-php-ext-configure \
    intl

RUN docker-php-ext-install -j$(nproc) \
    intl \
    pdo \
    pgsql \
    pdo_pgsql \
    opcache \
    zip \
    exif

## Install composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
CMD ["php-fpm"]
