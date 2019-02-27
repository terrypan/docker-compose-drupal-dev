# Docker Compose: Drupal8/PHP7/MySQL5.7

Vanilla Drupal development environment using [Docker Compose](https://docs.docker.com/compose/).

## Versions used

- Drupal 8.6.10
- Apache/2.4.25 (Debian)
- PHP 7.1.20
- MySQL 5.7.25

# Instructions

```
$ docker-compose up -d
```

Drupal files are located under `/app`<br>
MySQL data located under `/db-data` (not committed)

## Data export/import via drush

Find drupal container id, enter bash

```
$ docker exec -it CONTAINER_ID bash
```

Export db data

```
/app # drush cr
/app # drush sql-dump > ./mysql_dump.sql
```

Import db data

```
/app # drush sql-drop
/app # drush sql-cli < ./mysql_dump.sql
```

# Steps taken

Build images and start up

```
$ docker-compose up -d --build
```

Find drupal container id, enter bash

```
$ docker exec -it CONTAINER_ID bash
```

Install drupal via composer

```
/app #  composer create-project drupal-composer/drupal-project:8.x-dev /app --stability dev --no-interaction
/app #  mkdir -p /app/config/sync
/app #  chown -R www-data:www-data /app/web
```

Visit `http://localhost:8080` and complete drupal installation using:

```
db_name=drupal
db_user=drupal
db_pass=drupal
db_host=db (linked container name)
db_port=3306
```

Export drush config while in container

```
/app #  drush config-export
/app #  exit
```

Drush config is located at `/app/config/sync`
