# Docker Compose: Drupal8/PHP7/MySQL5.7

Vanilla Drupal development environment using [Docker Compose](https://docs.docker.com/compose/).

## Versions used

- Drupal 8.6.10
- Apache/2.4.25 (Debian)
- PHP 7.1.20
- MySQL 5.7.25

# Instructions

1. Edit `.env` where appropriate, default values:

```
MYSQL_PORT=3306
DRUPAL_PORT=8080

MYSQL_USER=drupal
MYSQL_PASSWORD=drupal
MYSQL_DATABASE=drupal
```

2. Run bootstrap script:

```
$ sh bootstrap.sh
```

#### Bootstrap steps

Runs in order:

- `(on host) docker-compose up -d`
- `(on drupal container) composer install`
- `(on drupal container) drush si -y {params}`
- `(on drupal container) drush config-set "system.site" uuid {migration_uuid} -y`
- `(on drupal container) drush {remove_placeholders}`
- `(on drupal container) drush cim -y`
- `(on drupal container) drush drush php-eval 'node_access_rebuild();'`

Drupal files are located under `/app`<br>
MySQL data located under `/db-data` (not committed)

## Data export/import via drush

Attach to drupal's container bash

```
$ docker exec -it $(docker ps -aqf "name=app.drupal") bash
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

Attach to drupal's container bash

```
$ docker exec -it $(docker ps -aqf "name=app.drupal") bash
```

Export drush config while in container

```
/app #  drush config-export
/app #  exit
```

Drush config is located at `/app/config/sync`
