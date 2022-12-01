FROM php:8.1.11-fpm

EXPOSE 80/TCP

VOLUME /var/lib/docker-agent/config/glpi
VOLUME /var/lib/docker-agent/lib/glpi
VOLUME /var/lib/docker-agent/log/nginx
VOLUME /var/lib/docker-agent/log/glpi
VOLUME /var/www/glpi/install
VOLUME /var/www/glpi/marketplace
VOLUME /var/www/glpi/plugins

ENV TERM xterm
ENV TZ Europe/Warsaw
ENV DEBIAN_FRONTEND noninteractive

ARG GLPI_VERSION=10.0.5

# Update APK and install dependencies
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        nano \
        nginx \
        libbz2-dev \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libldap2-dev \
        libpng-dev \
        libxml2-dev \
        libzip-dev \
        python3 \
        python3-pip \
        wget && \
    apt-get autoremove -y && \
    apt-get clean -y

# Install additional PHP extensions
# https://glpi-install.readthedocs.io/en/latest/prerequisites.html#mandatory-extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install bz2 exif gd simplexml intl ldap mysqli opcache zip

# Install Supervisor
RUN pip3 install supervisor

# Use the default production configuration
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# Prepare directories for configuration files
RUN mkdir -p /var/lib/docker-agent/config/supervisor && \
    mkdir -p /var/lib/docker-agent/config/glpi && \
    mkdir -p /var/lib/docker-agent/log/nginx && \
    mkdir -p /var/lib/docker-agent/log/glpi && \
    mkdir -p /var/lib/docker-agent/lib/glpi && \
    chown -R www-data:www-data /var/lib/docker-agent/config/glpi && \
    chown -R www-data:www-data /var/lib/docker-agent/log/nginx && \
    chown -R www-data:www-data /var/lib/docker-agent/log/glpi && \
    chown -R www-data:www-data /var/lib/docker-agent/lib/glpi

# Services configuration
COPY ./conf/php/custom.ini /usr/local/etc/php/conf.d/zzz-custom.ini
COPY ./conf/nginx/sites/default.conf /etc/nginx/sites-available/default
COPY ./conf/supervisor/supervisor.conf /var/lib/docker-agent/config/supervisor.conf

# Copy entrypoint script
COPY ./entrypoint.sh /var/lib/docker-agent/entrypoint.sh
RUN chmod +x /var/lib/docker-agent/entrypoint.sh

# Download specified version of the GLPI
RUN wget https://github.com/glpi-project/glpi/releases/download/${GLPI_VERSION}/glpi-${GLPI_VERSION}.tgz -O /root/project-archive.tgz && \
    tar zxvf /root/project-archive.tgz -C /var/www

# Prepare secure directories locations
# https://glpi-install.readthedocs.io/en/latest/install/index.html#files-and-directories-locations
RUN mv /var/www/glpi/files/* /var/lib/docker-agent/lib/glpi

COPY ./conf/glpi/inc/downstream.php /var/www/glpi/inc
COPY ./conf/glpi/local_define.php /var/lib/docker-agent/config/glpi

# Remove GLPI source archive & change owner of the destination directory
RUN rm /root/project-archive.tgz && \
    chown -R www-data:www-data /var/www/glpi && \
    chown -R www-data:www-data /var/lib/docker-agent/config/glpi && \
    chown -R www-data:www-data /var/lib/docker-agent/lib/glpi && \
    chown -R www-data:www-data /var/lib/docker-agent/log/glpi

# Switch workdir
WORKDIR /var/www/glpi

CMD ["/var/lib/docker-agent/entrypoint.sh"]
