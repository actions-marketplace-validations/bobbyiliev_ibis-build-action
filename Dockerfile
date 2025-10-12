# Multi-stage build for better caching and smaller image
FROM composer:2.7 AS composer-stage
WORKDIR /app
# Create a minimal composer.json for ibis-next installation
RUN echo '{"require":{"hi-folks/ibis-next":"^2.0"}}' > composer.json
# Install dependencies - this layer will be cached
RUN composer install --no-dev --optimize-autoloader --no-scripts

FROM php:8.4-cli-alpine AS runtime

LABEL "repository"="https://github.com/bobbyiliev/ibis-build-action"
LABEL "homepage"="https://github.com/bobbyiliev/ibis-build-action" 
LABEL "maintainer"="Bobby Iliev"

# Set environment variables for better caching
ENV COMPOSER_HOME=/tmp \
    COMPOSER_ALLOW_SUPERUSER=1

# Install system dependencies in one layer with cache mount
RUN --mount=type=cache,target=/var/cache/apk \
    apk update && \
    apk add --no-cache \
        libpng-dev \
        libjpeg-turbo-dev \
        freetype-dev \
        libzip-dev \
        git \
        icu-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd zip intl

# Copy Composer from official image (faster than downloading)
COPY --from=composer:2.7 /usr/bin/composer /usr/local/bin/composer

# Copy pre-installed dependencies from composer stage
COPY --from=composer-stage /app/vendor /tmp/vendor

# Create symlink for ibis-next binary
RUN ln -s /tmp/vendor/bin/ibis-next /usr/local/bin/ibis-next

# Copy and set up entrypoint (do this last to maximize cache hits)
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
