FROM php:7.4.3-fpm-alpine
# PHP extensions

RUN set -ex \
    && apk add --update --no-cache nginx autoconf g++ make libpng-dev curl icu-dev \
    && pecl install redis \
    && docker-php-ext-enable redis \
    && docker-php-ext-configure gd \		
	&& docker-php-ext-install -j$(nproc) gd opcache pdo_mysql  sockets fileinfo
RUN { \
        echo 'opcache.memory_consumption=128'; \
        echo 'opcache.interned_strings_buffer=8'; \
        echo 'opcache.max_accelerated_files=4000'; \
        echo 'opcache.revalidate_freq=2'; \
        echo 'opcache.fast_shutdown=1'; \
        echo 'opcache.enable_cli=1'; \
    } > /usr/local/etc/php/conf.d/php-opocache-cfg.ini
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

COPY default.conf /etc/nginx/conf.d/default.conf
COPY nginx-site.conf /etc/nginx/sites-enabled/default
COPY entrypoint.sh /etc/entrypoint.sh
COPY index.html /var/www/html/public/index.html
COPY info.php /var/www/html/public/info.php
RUN chmod +x /etc/entrypoint.sh
RUN mkdir /run/nginx



RUN adduser -DH -G www-data sail


EXPOSE 80 443

ENTRYPOINT ["/etc/entrypoint.sh"]
