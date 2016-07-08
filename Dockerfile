FROM cheezykins/laravel:latest
MAINTAINER Chris Stretton - https://github.com/cheezykins
RUN pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && mkdir /var/www/html/public/cachegrind \
	&& chown -R www-data:www-data /var/www/html \
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
