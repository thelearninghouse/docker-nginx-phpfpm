FROM php:8.2.7-fpm-alpine
LABEL Maintainer="Ray Hernandez <rahernande@wiley.com>"

ENV PHP_VERSION 8
ENV PHP_CONFIG_DIR /etc/php8

# Install Nginx, PHP-FPM, Supervisor, and PHP support libs
RUN apk --no-cache add \
    libmcrypt-dev \
    libzip-dev \
    alpine-sdk \
    autoconf \
    nginx \
    supervisor \
    curl \
    git

# add missing extensions
#RUN pecl install mcrypt && docker-php-ext-enable mcrypt
RUN docker-php-ext-install pdo_mysql && \
    docker-php-ext-install zip && \
    docker-php-ext-install opcache

# take rid of alpine-sdk & autoconf here
# they are only used for the plugin installs
RUN apk del alpine-sdk autoconf

# Setup application user/group/cwd
RUN adduser -D -g 'www' www && \
    mkdir -p /app/public && \
    chown -R www:www /app && \
    chown -R www:www /var/lib/nginx
WORKDIR /app

# setup parking screen
# COPY www/info.php /app/public/info.php
RUN chown -R www:www /app/public

# Configure Nginx
RUN touch /var/run/nginx.pid && \
    chown www:www /var/run/nginx.pid
COPY configs/nginx.conf /etc/nginx/nginx.conf
COPY configs/nginx.www.conf /etc/nginx/conf.d/default.conf

# hack for php-fpm
RUN addgroup www-data www

# Configure PHP-FPM
RUN touch /var/run/php-fpm.pid && \
    chown -R www:www /var/run/php-fpm.pid
COPY configs/php.ini ${PHP_CONFIG_DIR}/php.ini
COPY configs/php-fpm.conf ${PHP_CONFIG_DIR}/php-fpm.conf
RUN sed -i "s|{{php_version}}|${PHP_VERSION}|g" ${PHP_CONFIG_DIR}/php-fpm.conf
COPY configs/php.www.conf ${PHP_CONFIG_DIR}/php-fpm.d/www.conf

# Configure PHP-FPM logging
RUN mkdir -p /var/log/php${PHP_VERSION} && \
    mkfifo -m 666 /var/log/php${PHP_VERSION}/stdout && \
    mkfifo -m 666 /var/log/php${PHP_VERSION}/stderr

# Configure file uploads
RUN mkdir -p /var/tmp/nginx/client_body && \
    chown -R nginx:www /var/tmp/nginx && \
    chmod 770 /var/tmp/nginx && \
    chmod -R 770 /var/tmp/nginx/client_body

# Install Composer
COPY scripts/install_composer.sh /root
RUN chmod 755 /root/install_composer.sh && \
    cd /root && \
    ./install_composer.sh
ENV PATH="/root/.composer/vendor/bin:${PATH}"
RUN rm -rf /root/.composer/cache

# Available Ports
EXPOSE 80

# Setup container runtime
COPY configs/supervisord${PHP_VERSION}.conf /etc/supervisord.conf
RUN sed -i "s|{{php_version}}|${PHP_VERSION}|g" /etc/supervisord.conf
COPY scripts/supervisord-watchdog /sbin/supervisord-watchdog
RUN chmod 755 /sbin/supervisord-watchdog && \
    touch /var/run/supervisord.pid && \
    mkdir -p /var/log/supervisord
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
