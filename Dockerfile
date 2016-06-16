FROM php:5.6-apache
MAINTAINER Chris Stretton - https://github.com/cheezykins
RUN a2enmod rewrite
WORKDIR /var/www
RUN apt-get update && apt-get install --no-install-recommends -y \
    libgmp10 \
    libgmp-dev \
    mysql-client \
    zlib1g-dev \
    && ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/include/gmp.h \
    && docker-php-ext-install -j$(nproc) \
    bcmath \
    gmp \
    mbstring \
    mysql \
    pdo \
    pdo_mysql \
    zip \
    && pecl install \
    spl_types \
    xdebug \
    && docker-php-ext-enable spl_types xdebug \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && composer create-project \
    --no-ansi \
    --no-dev \
    --no-interaction \
    --no-progress \
    --prefer-dist \
    laravel/laravel /var/www/html ~5.2.0 \
    && rm -f /var/www/html/database/migrations/*.php \
    /var/www/html/app/Users.php \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir /var/www/html/public/cachegrind \
	&& chown -R www-data:www-data /var/www/html \
	&& sed -i 's/DocumentRoot \/var\/www\/html/DocumentRoot \/var\/www\/html\/public/g' /etc/apache2/apache2.conf \
	&& echo 'xdebug.profiler_output_dir = /var/www/html/public/cachegrind' >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
	&& echo 'xdebug.profiler_enable = 1' >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo 'xdebug.profiler_output_name = cachegrind.%u.%R' >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
	&& echo 'Options +Indexes' > /var/www/html/public/cachegrind/.htaccess

ONBUILD RUN composer self-update \
        && cd /var/www/html \
        && composer update \
        --no-ansi \
        --no-dev \
        --no-interaction \
        --no-progress \
        --prefer-dist
WORKDIR /var/www/html
