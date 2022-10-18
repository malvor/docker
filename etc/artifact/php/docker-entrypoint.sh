#!/bin/sh
set -e

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- php-fpm "$@"
fi

if [ "$1" = 'php-fpm' ] || [ "$1" = 'bin/console' ]; then
	mkdir -p var/cache var/log public/media
	setfacl -R -m u:www-data:rwX -m u:"$(whoami)":rwX var public/media
	setfacl -dR -m u:www-data:rwX -m u:"$(whoami)":rwX var public/media
	bin/console doctrine:migrations:migrate --no-interaction
  if [ "$APP_ENV" != 'dev' ]; then
    bin/console doctrine:migrations:migrate --no-interaction --env=test
  fi
fi

exec docker-php-entrypoint "$@"
