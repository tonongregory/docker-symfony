.ONESHELL:
SHELL := /bin/bash

DOCKER_RUN_PHP = docker-compose -f .docker/docker-compose.yml -f .docker/docker-compose.override.yml run --rm php "bash" "-c"
DOCKER_COMPOSE = docker-compose -f .docker/docker-compose.yml -f .docker/docker-compose.override.yml

env:
	@if [ ! -f "./.docker/.env" ]; then\
		cat ./.docker/.env.dist | sed  -e "s/{UID}/$(shell id --user)/" -e "s/{GID}/$(shell id --group)/" | tee ./.docker/.env
	fi
	@if [ ! -f "./.docker/docker-compose.override.yml" ]; then\
		cp ./.docker/docker-compose.override.yml.dist ./.docker/docker-compose.override.yml
	fi

src/vendor:
	$(DOCKER_RUN_PHP) "composer install --no-interaction"

up: env#[Docker] Start containers
	$(DOCKER_COMPOSE) up --remove-orphans --detach
	$(MAKE) src/vendor
	$(MAKE) server/start

stop: #[Docker] Down containers
	$(DOCKER_COMPOSE) stop

down: #[Docker] Down containers
	$(DOCKER_COMPOSE) down

server/start: #[Symfony] Start Symfony http server
	$(DOCKER_COMPOSE) exec -u $$(id -u $${USER}):$$(id -g $${USER}) php "bash" "-c" "symfony serve -d --no-tls"

server/stop: #[Symfony] Stop Symfony http server
	$(DOCKER_COMPOSE) exec -u $$(id -u $${USER}):$$(id -g $${USER}) php "bash" "-c" "symfony server:stop"

server/restart: server/stop server/start

build: .env #[Docker] Build containers
	$(DOCKER_COMPOSE) build

ps: # [Docker] Show running containers
	$(DOCKER_COMPOSE) ps

bash: .env #[Docker] Connect to php container with current host user
	$(DOCKER_COMPOSE) exec -u $$(id -u $${USER}):$$(id -g $${USER}) php bash

node: #[Docker] Connect to node container
	$(DOCKER_COMPOSE) run --rm -u $$(id -u $${USER}):$$(id -g $${USER}) node bash

yarn-install: #[Docker] Yarn package installation
	$(DOCKER_COMPOSE) run --rm -u $$(id -u $${USER}):$$(id -g $${USER}) node "bash" "-c" "yarn install"

yarn-watch: yarn-install #[Docker] Connect to yarn container
	$(DOCKER_COMPOSE) run --rm -u $$(id -u $${USER}):$$(id -g $${USER}) node "bash" "-c" "yarn run webpack --watch"

yarn-prod: #[Docker] Connect to yarn container
	$(DOCKER_COMPOSE) run --rm -u $$(id -u $${USER}):$$(id -g $${USER}) node "bash" "-c" "yarn encore prod"

yarn-dev: #[Docker] Connect to yarn container
	$(DOCKER_COMPOSE) run --rm -u $$(id -u $${USER}):$$(id -g $${USER}) node "bash" "-c" "yarn encore dev"

logs: #[Docker] Show logs
	$(DOCKER_COMPOSE) logs -f

cache-clean: #[Symfony] Clean cache
	$(DOCKER_RUN_PHP) "bin/console c:c"

doctrine-migrations: #[Symfony] Run doctrine migrations
	$(DOCKER_RUN_PHP) "bin/console doctrine:migrations:migrate -n"

xdebug-enable: #[Docker] Enable xdebug extension
	sed -i 's/XDEBUG_MODE=off/XDEBUG_MODE=debug/g' ./.docker/.env && $(DOCKER_COMPOSE) stop php && $(DOCKER_COMPOSE) up --detach php
	$(MAKE) server/restart
xdebug-disable: #[Docker] Disable xdebug extension
	sed -i 's/XDEBUG_MODE=debug/XDEBUG_MODE=off/g' ./.docker/.env && $(DOCKER_COMPOSE) stop php && $(DOCKER_COMPOSE) up --detach php
	$(MAKE) server/restart
