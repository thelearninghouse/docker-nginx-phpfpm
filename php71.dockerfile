FROM alpine:3.7
LABEL Maintainer="Michael Bunch <mbunch@learninghouse.com>"

ENV PHP_VERSION 7
ENV PHP_CONFIG_DIR /etc/php7

# Install Nginx, PHP-FPM, and Supervisor
RUN apk --no-cache add \
    nginx \
    supervisor \
    curl \
    php7 \
    php7-ctype \
    php7-curl \
    php7-dom \
    php7-fileinfo \
    php7-fpm \
    php7-json \
    php7-mbstring \
    php7-mcrypt \
    php7-opcache \
    php7-pdo_mysql \
    php7-phar \
    php7-session \
    php7-tokenizer \
    php7-zip \
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

# Setup container runtime
COPY scripts/entrypoint.sh /sbin/entrypoint.sh
COPY scripts/optimize_laravel.sh /sbin/optimize_laravel
COPY configs/supervisord.conf /etc/supervisor/supervisord.conf
RUN rm /etc/supervisord.conf
RUN mkdir /etc/supervisor/conf.d
RUN sed -i "s|{{php_version}}|${PHP_VERSION}|g" /etc/supervisor/supervisord.conf
COPY scripts/supervisord-watchdog /sbin/supervisord-watchdog
RUN chmod 755 /sbin/entrypoint.sh && \
    chmod 755 /sbin/export_secrets && \
    chmod 755 /sbin/optimize_laravel && \
    chmod 755 /sbin/supervisord-watchdog && \
    touch /var/run/supervisord.pid && \
    mkdir -p /var/log/supervisord
CMD ["/sbin/entrypoint.sh"]
