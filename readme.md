# Docker for Nginx / PHP-FPM

[![View on Docker Hub](https://img.shields.io/badge/Docker%20Hub-View-green.svg?style=for-the-badge)](http://hub.docker.com/r/learninghouse/nginx-phpfpm)

## Versions

### PHP 7.3 (`php73.dockerfile`)

- Alpine Linux 3.10
- PHP 7.3
- Nginx 1.16
- Supervisor 3.3

### PHP 7.2 (`php72.dockerfile`)

- Alpine Linux 3.8
- PHP 7.2
- Nginx 1.14
- Supervisor 3.3

### PHP 7.1.blackfire (`php71blackfire.dockerfile`)

- Alpine Linux 3.7
- PHP 7.1
- Nginx 1.12
- Supervisor 3.3

### PHP 7.1 (`php71.dockerfile`)

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
make php73   # PHP 7.3
make php72   # PHP 7.2
make php71   # PHP 7.1
```

## Tests

Testing on the images is performed with [Google's Container Structure Test](https://github.com/GoogleContainerTools/container-structure-test)
suite. The tests are located in the `/tests` folder and are separated by what they are testing.

- `image_tests.yaml` is for testing the state of the image and it's metadata.
- `nginx_tests.yaml` if for testing all things Nginx.
- `php_tests.yaml` if for testing all things PHP and application settings.
- `supervisord_tests.yaml` if for testing all things Supervisord.

To run the tests locally, build the image you wish to test and run the tests. Below is a example of testing the PHP 7.3 image.

```bash
make php73
container-structure-test test \
    --image learninghouse/nginx-phpfpm:7.3 \
    --config tests/image_tests.yaml \
    --config tests/nginx_tests.yaml \
    --config tests/php_tests.yaml \
    --config tests/supervisord_tests.yaml
```
