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
echo "Good to go!"