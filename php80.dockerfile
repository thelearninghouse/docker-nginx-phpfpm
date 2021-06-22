FROM alpine:3.14
LABEL Maintainer="Patrick Tinsley <ptinsley@wiley.com>"

ENV PHP_VERSION 8
ENV PHP_CONFIG_DIR /etc/php8

# Install Nginx, PHP-FPM, and Supervisor
RUN apk --no-cache add \
    nginx \
    supervisor \
    curl \
    php8 \
    php8-ctype \
    php8-curl \
    php8-dom \
    php8-fileinfo \
    php8-fpm \
    php8-json \
    php8-mbstring \
#    php8-mcrypt \
    php8-opcache \
    php8-pdo_mysql \
    php8-phar \
    php8-session \
    php8-tokenizer \
    php8-zip \
    git

RUN ln -s /usr/bin/php8 /usr/bin/php

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

# Configure PHP-FPM
RUN touch /var/run/php-fpm.pid && \
    chown -R www:www /var/run/php-fpm.pid
COPY configs/php.ini ${PHP_CONFIG_DIR}/php.ini
COPY configs/php-fpm.conf ${PHP_CONFIG_DIR}/php-fpm.conf
RUN sed -i "s|{{php_version}}|${PHP_VERSION}|g" ${PHP_CONFIG_DIR}/php-fpm.conf
COPY configs/php.www.conf ${PHP_CONFIG_DIR}/php-fpm.d/www.conf

# Configure PHP-FPM logging
RUN mkfifo -m 666 /var/log/php${PHP_VERSION}/stdout && \
    mkfifo -m 666 /var/log/php${PHP_VERSION}/stderr

# Configure file uploads
RUN mkdir /var/tmp/nginx && \
    chown -R nginx:www /var/tmp/nginx && \
    chmod 770 /var/tmp/nginx && \
    mkdir -p /var/tmp/nginx/client_body && \
    chmod -R 770 /var/tmp/nginx/client_body

# Install Composer
COPY scripts/install_composer.sh /root
RUN chmod 755 /root/install_composer.sh && \
    cd /root && \
    ./install_composer.sh
ENV PATH="/root/.composer/vendor/bin:${PATH}"

# Available Ports
EXPOSE 80

# Setup container runtime
COPY configs/supervisord.conf /etc/supervisord.conf
RUN sed -i "s|{{php_version}}|${PHP_VERSION}|g" /etc/supervisord.conf
COPY scripts/supervisord-watchdog /sbin/supervisord-watchdog
RUN chmod 755 /sbin/supervisord-watchdog && \
    touch /var/run/supervisord.pid && \
    mkdir -p /var/log/supervisord
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
