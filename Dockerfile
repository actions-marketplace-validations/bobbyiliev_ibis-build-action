FROM php:8.4-cli-alpine

LABEL "repository"="https://github.com/bobbyiliev/ibis-build-action"
LABEL "homepage"="https://github.com/bobbyiliev/ibis-build-action" 
LABEL "maintainer"="Bobby Iliev"

ENV COMPOSER_HOME=/tmp \
    COMPOSER_ALLOW_SUPERUSER=1

# Install system dependencies and PHP extensions (this layer caches well)
RUN --mount=type=cache,target=/var/cache/apk \
    apk update && apk add --no-cache \
        libpng libjpeg-turbo freetype libzip icu-libs git \
        libpng-dev libjpeg-turbo-dev freetype-dev libzip-dev icu-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd zip intl \
    && apk del libpng-dev libjpeg-turbo-dev freetype-dev libzip-dev icu-dev

# Install Composer and ibis-next (separate layer for better caching)
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN --mount=type=cache,target=/root/.composer \
    composer global require hi-folks/ibis-next:^2.0 --no-dev --optimize-autoloader \
    && ln -s /tmp/vendor/bin/ibis-next /usr/local/bin/ibis-next

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
