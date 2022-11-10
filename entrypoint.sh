#!/bin/bash

exec /usr/local/bin/supervisord -c /var/lib/docker-agent/config/supervisor.conf
