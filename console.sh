#!/bin/bash

docker exec -it glpi-application /usr/local/bin/php /var/www/glpi/bin/console "$@"
