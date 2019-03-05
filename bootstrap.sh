#!/bin/bash
echo "@@@@ Bootstraping @@@@"

echo "->Starting docker containers with deamon (-d)..."
docker-compose up -d
echo "Done"

echo "->Running: composer install"
docker exec -it $(docker ps -aqf "name=app.drupal") bash -c "composer install"
echo "->Running: drush si..."
docker exec -it $(docker ps -aqf "name=app.drupal") bash -c "drush si -y \
  --site-name=\"Tennis tournie\"   \
  --account-name=drupal   \
  --account-pass=drupal   \
  --db-url=mysql://drupal:drupal@db:3306/drupal"
echo "Site installed successfully!"


echo "->Running: edit system.site.uuid to match migration"

# set system.site.uuid to migration's uuid
docker exec -it $(docker ps -aqf "name=app.drupal") bash -c "drush config-set \"system.site\" uuid 64a21b82-14bd-4631-95ba-f9ecba6af357 -y"

# next command needed to fix core issue: https://www.drupal.org/node/2583113
docker exec -it $(docker ps -aqf "name=app.drupal") bash -c "drush ev '\Drupal::entityManager()->getStorage(\"shortcut_set\")->load(\"default\")->delete();'"

echo "->Running: import configuration from app/config/sync..."
# import config
docker exec -it $(docker ps -aqf "name=app.drupal") bash -c "drush cim -y"
echo "->Config imported!!"

echo "->Running: Drush fix permissions"
# fix permissions
docker exec -it $(docker ps -aqf "name=app.drupal") bash -c "drush php-eval 'node_access_rebuild();'"


echo "Good to go! There should be no issue on http://localhost:8080/admin/config/development/configuration"