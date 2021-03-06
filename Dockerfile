FROM drupal:8.6.10-apache

RUN apt-get update && apt-get install -y \
  curl \
  git \
  mysql-client \
  vim \
  wget

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
  php composer-setup.php && \
  mv composer.phar /usr/local/bin/composer && \
  php -r "unlink('composer-setup.php');"

RUN wget -O drush.phar https://github.com/drush-ops/drush-launcher/releases/download/0.4.2/drush.phar && \
  chmod +x drush.phar && \
  mv drush.phar /usr/local/bin/drush

RUN curl https://drupalconsole.com/installer -L -o drupal.phar && \
  mv drupal.phar /usr/local/bin/drupal && \
  chmod +x /usr/local/bin/drupal

RUN rm -rf /var/www/html/*

COPY apache-drupal.conf /etc/apache2/sites-enabled/000-default.conf

RUN composer create-project drupal-composer/drupal-project:8.x-dev /app --stability dev --no-interaction && \ 
  mkdir -p /app/config/sync && \
  chown -R www-data:www-data /app/web

WORKDIR /app
RUN composer require drush/drush:9.5.2

# Fix permissions
RUN chmod 775 ./web/sites/default && \
  chmod 775 ./web/sites/default/settings.php 
# chmod 775 ./web/sites/default/settings.php.template
