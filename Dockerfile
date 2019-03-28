FROM php:5.6-apache
MAINTAINER Pinnacle Solutions, Inc. - https://github.com/psiconsultants
RUN a2enmod rewrite
COPY 010-default.conf /etc/apache2/sites-available
WORKDIR /var/www
RUN apt-get update && apt-get install --no-install-recommends -y \
    libgmp10 \
    libgmp-dev \
    libldb-dev \
    libldap2-dev \
    mysql-client \
    zlib1g-dev \
    unzip \
    gnupg \
    dirmngr \
    && ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/include/gmp.h \
    && ln -s /usr/lib/x86_64-linux-gnu/libld* /usr/lib/ \
    && docker-php-ext-install -j$(nproc) \
    bcmath \
    gmp \
    ldap \
    mbstring \
    mysql \
    pdo \
    pdo_mysql \
    zip \
    && a2dissite 000-default \
    && a2ensite 010-default \
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
    && rm -rf /var/lib/apt/lists/*
RUN chown -R www-data:www-data /var/www/html
ONBUILD RUN composer self-update \
        && cd /var/www/html \
        && composer update \
        --no-ansi \
        --no-dev \
        --no-interaction \
        --no-progress \
        --prefer-dist

RUN groupadd --gid 1000 node \
  && useradd --uid 1000 --gid node --shell /bin/bash --create-home node

# gpg keys listed at https://github.com/nodejs/node
RUN set -ex \
  && for key in \
    4ED778F539E3634C779C87C6D7062848A1AB005C \
    B9E2F5981AA6E0CD28160D9FF13993A75599653C \
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
    B9AE9905FFD7803F25714661B63B535A4C206CA9 \
    77984A986EBC2AA786BC0F66B01FBB92821C587A \
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
    FD3A5288F042B6850C66B31F09FE44734EB7990E \
    8FCCA13FEF1D0C2E91008E09770F7A9A5AE15600 \
    C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
    DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
    A48C2BEE680E841632CD4E44F07496B3EB3C1762 \
  ; do \
    gpg --keyserver pool.sks-keyservers.net --recv-keys "$key"; \
  done

ENV NPM_CONFIG_LOGLEVEL info
ENV NODE_VERSION 0.0.0

RUN curl -sL https://deb.nodesource.com/setup_6.x | bash - \
  && apt-get install -y nodejs bzip2 libfontconfig openssh-client \
  && npm install -g gulp

WORKDIR /var/www/html
