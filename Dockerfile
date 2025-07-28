# Base image with Apache and PHP
FROM php:8.2-apache

# Install required PHP extensions
RUN apt-get update && apt-get install -y \
    libpng-dev libjpeg-dev libonig-dev libxml2-dev zip unzip curl \
    && docker-php-ext-install pdo pdo_mysql mysqli

# Enable Apache URL rewriting
RUN a2enmod rewrite

# Set Dolibarr version
ENV DOLIBARR_VERSION 18.0.2

# Download and extract Dolibarr
RUN curl -L https://github.com/Dolibarr/dolibarr/archive/refs/tags/${DOLIBARR_VERSION}.zip -o /tmp/dolibarr.zip \
    && unzip /tmp/dolibarr.zip -d /var/www/html \
    && mv /var/www/html/dolibarr-${DOLIBARR_VERSION}/htdocs/* /var/www/html/ \
    && rm -rf /var/www/html/dolibarr-${DOLIBARR_VERSION} /tmp/dolibarr.zip

# Set permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# Expose port
EXPOSE 8080

# Change default Apache port to 8080 (Cloud Run requirement)
RUN sed -i 's/80/8080/g' /etc/apache2/ports.conf /etc/apache2/sites-enabled/000-default.conf

# Launch Apache
CMD ["apache2-foreground"]
