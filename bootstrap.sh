#!/bin/sh
GREEN="\e[92m"
YELLOW="\e[33m"
STOP="\e[0m"

printf "%s--->${YELLOW}@@@@ Bootstraping @@@@${STOP}\n"

printf "%s--->${YELLOW}Starting docker containers with deamon (-d)...${STOP}\n"
docker-compose up -d
printf "%s--->${GREEN} docker containers up and running!${STOP}\n"

printf "%s--->${YELLOW}Running: composer install${STOP}\n"
docker exec -it $(docker ps -aqf "name=app.drupal") bash -c "composer install"
printf "%s--->${YELLOW}Running: drush site-install...${STOP}\n"
docker exec -it $(docker ps -aqf "name=app.drupal") bash -c "drush si -y \
  --site-name=\"Tennis tournie\"   \
  --account-name=drupal   \
  --account-pass=drupal   \
  --db-url=mysql://drupal:drupal@db:3306/drupal"
printf "%s--->${GREEN}Site installed successfully!${STOP}\n"


printf "%s--->${YELLOW}Running: edit system.site.uuid to match migration${STOP}\n"

# set system.site.uuid to migration's uuid
docker exec -it $(docker ps -aqf "name=app.drupal") bash -c "drush config-set \"system.site\" uuid 64a21b82-14bd-4631-95ba-f9ecba6af357 -y"

# next command needed to fix core issue: https://www.drupal.org/node/2583113
docker exec -it $(docker ps -aqf "name=app.drupal") bash -c "drush ev '\Drupal::entityManager()->getStorage(\"shortcut_set\")->load(\"default\")->delete();'"

printf "%s--->${YELLOW}Running: import configuration from app/config/sync...${STOP}\n"
# import config
docker exec -it $(docker ps -aqf "name=app.drupal") bash -c "drush cim -y"
printf "%s--->${GREEN}Config imported!!${STOP}\n"

printf "%s--->${YELLOW}Running: Drush fix permissions${STOP}\n"
# fix permissions
docker exec -it $(docker ps -aqf "name=app.drupal") bash -c "drush php-eval 'node_access_rebuild();'"

printf "%s--->${YELLOW}Running: Import database dump${STOP}\n"
docker exec -it $(docker ps -aqf "name=app.drupal") bash -c "drush sql-drop -y && drush sql-cli < ./mysql_dump.sql"
printf "%s--->${GREEN}Data import successful!${STOP}\n"

printf "%s--->${GREEN} Good to go! There should be no issue on http://localhost:8080/admin/config/development/configuration${STOP}\n"