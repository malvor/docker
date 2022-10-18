env=dev
compose=UID=${UID} GID=${GID} docker-compose -f etc/docker-compose.yml -f etc/$(env)/docker-compose.yml --env-file .env.docker

export compose env

.PHONY: start
start: erase build up

.PHONY: stop
stop:
		$(compose) stop $(s)

.PHONY: rebuild
rebuild: start

.PHONY: erase
erase: ## stop and delete containers, clean volumes.
		$(compose) stop
		$(compose) rm -v -f

.PHONY: build
build:
		$(compose) build
		if [ env = "prod" ]; then \
			echo Building in $(env) mode; \
			$(compose) run --rm php sh -lc 'xoff;COMPOSER_MEMORY_LIMIT=-1 composer install --no-ansi --no-dev --no-interaction --no-plugins --no-progress --no-scripts --no-suggest --optimize-autoloader'; \
		else \
			$(compose) run --rm php sh -lc 'xoff;COMPOSER_MEMORY_LIMIT=-1 composer install'; \
		fi

.PHONY: start-deps
start-deps:
		$(compose) run --rm start_dependencies

.PHONY: up
up:
		$(compose) up -d

.PHONY: cs-check
cs-check:
		$(compose) run --rm code sh -lc './vendor/bin/ecs check src tests'

.PHONY: phpstan
phpstan: ## executes php analizers
		$(compose) run --rm code ./vendor/bin/phpstan analyse -l 6 -c phpstan.neon src tests

.PHONY: psalm
psalm: ## execute psalm analyzer
		$(compose) run --rm code sh -lc './vendor/bin/psalm --show-info=false'

.PHONY: phpunit
phpunit:
		$(compose) exec -T php sh -lc "XDEBUG_MODE=coverage ./vendor/bin/phpunit $(conf)"

.PHONY: cs
cs:
		$(compose) run --rm code bin/php-cs-fixer fix --diff -v --path-mode="intersection" ./

.PHONY: migrations-diff
migrations-diff:
		$(compose) exec php bin/console doctrine:migrations:diff

.PHONY: migrations-migrate
migrations-migrate:
		$(compose) exec php bin/console doctrine:migrations:migrate

.PHONY: assets
assets:
		$(compose) exec nodejs gulp build
