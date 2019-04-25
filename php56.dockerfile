FROM alpine:3.7
LABEL Maintainer="Michael Bunch <mbunch@learninghouse.com>"

ENV PHP_VERSION 5
ENV PHP_CONFIG_DIR /etc/php5

# Install Nginx, PHP-FPM, and Supervisor
RUN apk --update --no-cache add \
    nginx \
    supervisor \
    curl \
    php5 \
    php5-cli \
    php5-mysql \
    php5-curl \
    php5-fpm \
    php5-json \
    php5-mcrypt \
    php5-opcache \
    php5-openssl \
    php5-pdo_mysql \
    php5-phar \
    php5-zip \
    php5-zlib \
    git

# Setup application user/group/cwd
RUN adduser -D -g 'www' www && \
    mkdir -p /app && \
    chown -R www:www /app && \
    chown -R www:www /var/lib/nginx
WORKDIR /app

# Configure Nginx
RUN touch /var/run/nginx.pid && \
    chown www:www /var/run/nginx.pid
COPY configs/nginx.conf /etc/nginx/nginx.conf
COPY configs/nginx.www.conf /etc/nginx/conf.d/default.conf

# Configure PHP-CLI
RUN ln -s /usr/bin/php5 /usr/bin/php

# Configure PHP-FPM
RUN touch /var/run/php-fpm.pid && \
    chown -R www:www /var/run/php-fpm.pid
COPY configs/php.ini ${PHP_CONFIG_DIR}/php.ini
COPY configs/php-fpm.conf ${PHP_CONFIG_DIR}/php-fpm.conf
RUN sed -i "s|{{php_version}}|${PHP_VERSION}|g" ${PHP_CONFIG_DIR}/php-fpm.conf
COPY configs/php.www.conf ${PHP_CONFIG_DIR}/php-fpm.d/www.conf

RUN mkdir /var/log/php${PHP_VERSION} && \
    mkfifo -m 666 /var/log/php${PHP_VERSION}/stdout && \
    mkfifo -m 666 /var/log/php${PHP_VERSION}/stderr

# Configure file uploads
RUN chown -R nginx:www /var/tmp/nginx && \
    chmod 770 /var/tmp/nginx && \
    mkdir -p /var/tmp/nginx/client_body && \
    chmod -R 770 /var/tmp/nginx/client_body

# Install Composer
COPY scripts/install_composer.sh /root
RUN chmod 755 /root/install_composer.sh && \
    cd /root && \
    ./install_composer.sh
ENV PATH="/root/.composer/vendor/bin:${PATH}"
RUN composer global require hirak/prestissimo && \
    rm -rf /root/.composer/cache

# Available Ports
EXPOSE 80

# Setup container entrypoint
COPY scripts/entrypoint.sh /sbin/entrypoint.sh
COPY scripts/export_secrets.sh /sbin/export_secrets
COPY scripts/optimize_laravel.sh /sbin/optimize_laravel
COPY configs/supervisord.conf /etc/supervisord.conf
RUN sed -i "s|{{php_version}}|${PHP_VERSION}|g" /etc/supervisord.conf
COPY scripts/supervisord-watchdog /sbin/supervisord-watchdog
RUN chmod 755 /sbin/entrypoint.sh && \
    chmod 755 /sbin/export_secrets && \
    chmod 755 /sbin/optimize_laravel && \
    chmod 755 /sbin/supervisord-watchdog && \
    touch /var/run/supervisord.pid && \
    mkdir -p /var/log/supervisord
CMD ["/sbin/entrypoint.sh"]
