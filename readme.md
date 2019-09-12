# Docker for Nginx / PHP-FPM

[![View on Docker Hub](https://img.shields.io/badge/Docker%20Hub-View-green.svg?style=for-the-badge)](http://hub.docker.com/r/learninghouse/nginx-phpfpm)

## Versions

### PHP 7.3 (`php73.dockerfile`)

[![MicroBadger Size](https://img.shields.io/microbadger/image-size/learninghouse/nginx-phpfpm/7.3.svg?style=for-the-badge)](https://hub.docker.com/r/learninghouse/nginx-phpfpm/) [![MicroBadger Size](https://img.shields.io/microbadger/layers/learninghouse/nginx-phpfpm/7.3.svg?style=for-the-badge)](https://hub.docker.com/r/learninghouse/nginx-phpfpm/)

- Alpine Linux 3.10
- PHP 7.3
- Nginx 1.16
- Supervisor 3.3

### PHP 7.2 (`php72.dockerfile`)

[![MicroBadger Size](https://img.shields.io/microbadger/image-size/learninghouse/nginx-phpfpm/7.2.svg?style=for-the-badge)](https://hub.docker.com/r/learninghouse/nginx-phpfpm/) [![MicroBadger Size](https://img.shields.io/microbadger/layers/learninghouse/nginx-phpfpm/7.2.svg?style=for-the-badge)](https://hub.docker.com/r/learninghouse/nginx-phpfpm/)

- Alpine Linux 3.8
- PHP 7.2
- Nginx 1.14
- Supervisor 3.3

### PHP 7.1 (`php71.dockerfile`)

[![MicroBadger Size](https://img.shields.io/microbadger/image-size/learninghouse/nginx-phpfpm/7.1.svg?style=for-the-badge)](https://hub.docker.com/r/learninghouse/nginx-phpfpm/) [![MicroBadger Size](https://img.shields.io/microbadger/layers/learninghouse/nginx-phpfpm/7.1.svg?style=for-the-badge)](https://hub.docker.com/r/learninghouse/nginx-phpfpm/)

- Alpine Linux 3.7
- PHP 7.1
- Nginx 1.12
- Supervisor 3.3

## Build

To build the images locally you can use the included `Makefile` for convenience.

## Build all images

```bash
make all
```

## Build specific PHP version

```bash
make php71   # PHP 7.1
make php72   # PHP 7.2
make php73   # PHP 7.3
```
