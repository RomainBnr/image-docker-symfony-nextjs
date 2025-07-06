# Dockerfile optimisé pour Symfony avec PHP-FPM
FROM php:8.3-fpm-alpine AS base

# Install system dependencies and PHP extensions
RUN apk add --no-cache \
        git \
        unzip \
        zip \
        curl \
        libzip-dev \
        libpq-dev \
        libxml2-dev \
        icu-dev \
        oniguruma-dev \
        netcat-openbsd \
        linux-headers \
        $PHPIZE_DEPS \
    && docker-php-ext-configure intl \
    && docker-php-ext-install -j$(nproc) \
        pdo_mysql \
        zip \
        intl \
        opcache \
        bcmath \
    && pecl install apcu \
    && docker-php-ext-enable apcu \
    && apk del $PHPIZE_DEPS \
    && rm -rf /var/cache/apk/*

# Configuration PHP optimisée pour production
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
COPY docker/php/php.ini /usr/local/etc/php/conf.d/custom.ini

# Create user
RUN addgroup -g 1000 www && \
    adduser -u 1000 -G www -s /bin/sh -D www

WORKDIR /var/www/html

# Development stage
FROM base AS development
RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"
COPY docker/php/start-optimized.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh
CMD ["/usr/local/bin/start.sh"]

# Production stage  
FROM base AS production
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# Copy application
COPY --chown=www:www backend/ .

# Install dependencies
RUN composer install --no-dev --optimize-autoloader --no-interaction --no-ansi

# Set permissions
RUN mkdir -p var/cache var/log public && \
    chown -R www:www var public && \
    chmod -R 775 var

# Warm up cache
RUN php bin/console cache:warmup --env=prod --no-debug

EXPOSE 9000
USER www

CMD ["php-fpm", "-F"]
