FROM alpine:edge
LABEL Maintainer="Michael Bunch <mbunch@learninghouse.com>"

# Install Nginx, PHP-FPM, and Supervisor
RUN apk --no-cache add \
    nginx \
    supervisor \
    curl \
    php7 \
    php7-ctype \
    php7-curl \
    php7-dom \
    php7-fpm \
    php7-json \
    php7-mbstring \
    php7-mcrypt \
    php7-opcache \
    php7-pdo_mysql \
    php7-phar \
    php7-session \
    php7-tokenizer \
    php7-zip

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
COPY configs/laravel.nginx.conf /etc/nginx/conf.d/default.conf

# Configure PHP-FPM
RUN touch /var/run/php-fpm.pid && \
    chown -R www:www /var/run/php-fpm.pid
COPY configs/php.ini /etc/php7/php.ini
COPY configs/php-fpm.conf /etc/php7/php-fpm.conf
COPY configs/laravel.php.conf /etc/php7/php-fpm.d/www.conf

# Install Composer
COPY scripts/install_composer.sh /root
RUN chmod 755 /root/install_composer.sh && \
    cd /root && \
    ./install_composer.sh

# Available Ports
EXPOSE 80

# Setup container runtime
COPY configs/supervisord.conf /etc/supervisord.conf
COPY scripts/supervisord-watchdog /sbin/supervisord-watchdog
RUN chmod 755 /sbin/supervisord-watchdog && \
    touch /var/run/supervisord.pid && \
    mkdir -p /var/log/supervisord
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
