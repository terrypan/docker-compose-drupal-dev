#!/bin/bash

docker_drupal_exec(){
  docker exec -it $(docker ps -aqf "name=${DRUPAL_CONTAINER}") bash -c  "$1"
}

# Load env variables from .env file
set -o allexport; source .env; set +o allexport

# Replace default settings in settings.php based on .env
chmod 775 app/web/sites/default/settings.php
chmod 775 app/web/sites/default/settings.php.template

sed -e "s/:MYSQL_DATABASE:/${MYSQL_DATABASE}/g" \
    -e "s/:MYSQL_USER:/${MYSQL_USER}/g" \
    -e "s/:MYSQL_PASSWORD:/${MYSQL_PASSWORD}/g" \
    -e "s/:MYSQL_PORT://g" \
    ./app/web/sites/default/settings.php.template > ./app/web/sites/default/settings.php


GREEN="\e[92m"
YELLOW="\e[33m"
STOP="\e[0m"

printf "%s--->${YELLOW}@@@@ Bootstraping @@@@${STOP}\n"

printf "%s--->${YELLOW}Starting docker containers with deamon (-d)...${STOP}\n"
docker-compose up -d
printf "%s--->${GREEN} docker containers up and running!${STOP}\n"

printf "%s--->${YELLOW}Running: composer install${STOP}\n"
docker_drupal_exec "composer install"
printf "%s--->${YELLOW}Running: drush site-install...${STOP}\n"
docker_drupal_exec "drush si standard -y \
  --root=/app
  --site-name=\"Tennis tournie\"   \
  --account-name=drupal   \
  --account-pass=drupal   \
  --db-url=mysql://${MYSQL_USER}:${MYSQL_PASSWORD}@db:${MYSQL_PORT}/${MYSQL_DATABASE}"
printf "%s--->${GREEN}Site installed successfully!${STOP}\n"
echo "--db-url=mysql://${MYSQL_USER}:${MYSQL_PASSWORD}@db:${MYSQL_PORT}/${MYSQL_DATABASE}"

printf "%s--->${YELLOW}Running: edit system.site.uuid to match migration${STOP}\n"

# set system.site.uuid to migration's uuid
docker_drupal_exec "drush config-set \"system.site\" uuid 64a21b82-14bd-4631-95ba-f9ecba6af357 -y"

# next command needed to fix core issue: https://www.drupal.org/node/2583113
docker_drupal_exec "drush ev '\Drupal::entityManager()->getStorage(\"shortcut_set\")->load(\"default\")->delete();'"

printf "%s--->${YELLOW}Running: import configuration from app/config/sync...${STOP}\n"
# import config
docker_drupal_exec "drush cim -y"
printf "%s--->${GREEN}Config imported!!${STOP}\n"

printf "%s--->${YELLOW}Running: Drush fix permissions${STOP}\n"
# fix permissions
docker_drupal_exec "drush php-eval 'node_access_rebuild();'"

# printf "%s--->${YELLOW}Running: Import database dump${STOP}\n"
# docker_drupal_exec "drush sql-drop -y && drush sql-cli < ./mysql_dump.sql"
# printf "%s--->${GREEN}Data import successful!${STOP}\n"

printf "%s--->${YELLOW}Running: Clear cache${STOP}\n"
docker_drupal_exec "drush cr"

printf "%s--->${GREEN} Good to go! There should be no issue on http://localhost:${DRUPAL_PORT}/admin/config/development/configuration${STOP}\n"