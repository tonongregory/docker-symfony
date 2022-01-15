DOCKER_RUN_PHP = docker-compose -f .docker/docker-compose.yml -f .docker/docker-compose.override.yml run --rm php "bash" "-c"
DOCKER_COMPOSE = docker-compose -f .docker/docker-compose.yml -f .docker/docker-compose.override.yml

src/vendor:
	$(DOCKER_RUN_PHP) "composer install --no-interaction"

upd: #[Docker] Start containers
	$(DOCKER_COMPOSE) up --detach --remove-orphans

stop: #[Docker] Down containers
	$(DOCKER_COMPOSE) stop

down: #[Docker] Down containers
	$(DOCKER_COMPOSE) down

build: #[Docker] Build containers
	$(DOCKER_COMPOSE) build

ps: # [Docker] Show running containers
	$(DOCKER_COMPOSE) ps

bash: #[Docker] Connect to php container with current host user
	$(DOCKER_COMPOSE) exec -u $$(id -u $${USER}):$$(id -g $${USER}) php bash

bash-root: #[Docker] Connect to php container with root user
	$(DOCKER_COMPOSE) exec -u root php bash

php: #[Docker] Run container with current host user
	$(DOCKER_COMPOSE) run --rm php bash

node: #[Docker] Connect to node container
	$(DOCKER_COMPOSE) run --rm -u $$(id -u $${USER}):$$(id -g $${USER}) node bash

yarn-install: #[Docker] Yarn package installation
	$(DOCKER_COMPOSE) run --rm -u $$(id -u $${USER}):$$(id -g $${USER}) node "bash" "-c" "yarn install"

yarn-watch: #[Docker] Connect to yarn container
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
	sed -i 's/PHP_XDEBUG_ENABLED=0/PHP_XDEBUG_ENABLED=1/g' ./.docker/.env && $(DOCKER_COMPOSE) stop php nginx && $(DOCKER_COMPOSE) up --detach php nginx

xdebug-disable: #[Docker] Disable xdebug extension
	sed -i 's/PHP_XDEBUG_ENABLED=1/PHP_XDEBUG_ENABLED=0/g' ./.docker/.env && $(DOCKER_COMPOSE) stop php nginx && $(DOCKER_COMPOSE) up --detach php nginx

messenger-consume-process:
	$(DOCKER_RUN_PHP) "bin/console messenger:consume run_process --memory-limit=256M --quiet"

messenger-consume-stock-process:
	$(DOCKER_RUN_PHP) "bin/console messenger:consume stock --memory-limit=256M --quiet"

phpstan: #[Quality] phpstan analyze
	$(DOCKER_RUN_PHP) "vendor/bin/phpstan analyze"

phpcs: #[Quality] phpcs
	$(DOCKER_RUN_PHP) "vendor/bin/phpcs"