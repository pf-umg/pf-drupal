FROM drupal:11-php8.3-apache
COPY --chown=www-data:www-data . /opt/drupal
