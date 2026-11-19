# Dockerfile endurecido (responsable: Stiven)
# Opcional: fijar la base por digest (ver paso 4 de la guia)
FROM drupal:11-php8.3-apache

# Apache en el puerto 8080 (un usuario sin privilegios no puede usar el 80)
# y sin revelar versiones de Apache ni de PHP (HC13)
RUN sed -i 's/^Listen 80$/Listen 8080/' /etc/apache2/ports.conf \
 && sed -i 's/<VirtualHost \*:80>/<VirtualHost *:8080>/' /etc/apache2/sites-available/000-default.conf \
 && sed -i 's/^ServerTokens .*/ServerTokens Prod/; s/^ServerSignature .*/ServerSignature Off/' /etc/apache2/conf-available/security.conf \
 && echo 'expose_php = Off' > /usr/local/etc/php/conf.d/zz-seguridad.ini

COPY --chown=www-data:www-data . /opt/drupal

# El contenedor ya no corre como root (HC10)
USER www-data
EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s CMD curl -fs http://localhost:8080/ || exit 1
