FROM php:8.3-fpm

# System dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    zip \
    unzip \
    libicu-dev \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip \
    && docker-php-ext-configure intl \
    && docker-php-ext-install intl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# PHP configuration
RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"

# Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Node.js y pnpm (en lugar de npm)
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g pnpm

# Crear usuario primero
RUN groupadd -g 1000 www && useradd -u 1000 -ms /bin/bash -g www www

WORKDIR /var/www

# Copiar archivos como root
COPY . /var/www

# Instalar dependencias como root (es más rápido)
RUN composer install --no-dev --optimize-autoloader --no-interaction \
    && pnpm install \
    && pnpm run build

# Cambiar propietario después de instalar
RUN chown -R www:www /var/www \
    && chmod -R 755 /var/www/storage \
    && chmod -R 755 /var/www/bootstrap/cache

# Cambiar a usuario no-root
USER www

EXPOSE 9000
CMD ["php-fpm"]
