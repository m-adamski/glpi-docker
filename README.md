# Docker GLPI & NGINX

Docker image with GLPI and NGINX.

* [GLPI Project](https://glpi-project.org)
* [Traefik Proxy](https://traefik.io/traefik/)

The image was prepared for private use and is not an official Docker image released by the GLPI publisher. The configuration has not been scanned for possible security vulnerabilities. Recommended use in the internal network without internet access.

## Additional configuration steps:

1. Generate secure credentials for MySQL database and fill docker-compose.yaml file

```yaml
environment:
    - MYSQL_USER=
    - MYSQL_PASSWORD=
    - MYSQL_DATABASE=
    - MYSQL_ROOT_PASSWORD=
```

2. Specify GLPI version which you want to download while building image - default: 10.0.5

```yaml
build:
    context: .
        args:
            GLPI_VERSION: 10.0.5
```

3. Choose domain for your GLPI instance and change it in service label - default: localhost

```yaml
labels:
    - traefik.enable=true
    - traefik.port=80
    - traefik.http.routers.glpi.rule=Host(`localhost`)
    - traefik.http.routers.glpi.tls=false
```

4. Enable SSL in service label and traefik configuration

```yaml
labels:
    - traefik.http.routers.glpi.tls=true
```

```yaml
entryPoints:
  web:
    address: ":80"
    http:
      redirections:
        entryPoint:
          to: websecure
          scheme: https

  websecure:
    address: ":443"

# TLS configuration
tls:
  certificates:
    - certFile: /certificates/STAR.example.com/STAR.example.com.pem
      keyFile: /certificates/STAR.example.com/STAR.example.com.key

```
