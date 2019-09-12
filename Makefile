docker_repo = learninghouse/nginx-phpfpm

help:
	@echo "Build PHP Docker base images."
	@echo "Usage:"
	@echo "  make all      Builds all Dockerfiles"
	@echo "  make php56    Build only the PHP 5.6 image"
	@echo "  make php71    Build only the PHP 7.1 image"
	@echo "  make php72    Build only the PHP 7.2 image"
	@echo "  make php73    Build only the PHP 7.3 image"

all: php56 php71 php72 php73

php56: php56.dockerfile
	docker build --no-cache -f $< -t $(docker_repo):5.6 .

php71: php71.dockerfile
	docker build --no-cache -f $< -t $(docker_repo):7.1 .

php72: php72.dockerfile
	docker build --no-cache -f $< -t $(docker_repo):7.2 .

php73: php73.dockerfile
	docker build --no-cache -f $< -t $(docker_repo):7.3 .
