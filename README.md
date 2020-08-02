# Dockerized HAProxy with Let's Encrypt automatic certificate renewal capabilities

This container provides an HAProxy instance with Let's Encrypt certificates generated
at startup, as well as renewed (if necessary) once a week with an internal cron job.

## Usage

### Pull from Docker Hub:

```
docker pull tomdess/haproxy-certbot
```

### Build from Dockerfile:

```
docker build -t docker-haproxy-certbot:latest .
```

### Run container:

Example of run command (replace CERTS,EMAIL values and volume paths with yours)

```
docker run --name lb -d \
    -e CERTS=my.domain,my.other.domain \
    -e EMAIL=my.email@my.domain \
    -v /srv/letsencrypt:/etc/letsencrypt \
    -v /srv/haproxycfg/haproxy.cfg:/etc/haproxy/haproxy.cfg \
    --network my_network \
    -p 80:80 -p 443:443 \
    tomdess/haproxy-certbot:latest
```

### Run with docker-compose:

Use the docker-compose.yml file in `run` directory (it creates 2 containers, the haproxy one and a nginx container linked in haproxy configuration for test purposes)

```
# docker-compose.yml file content:

version: '3'
services:
    haproxy:
        container_name: lb
        environment:
            - CERTS=my.domain
            - EMAIL=my.mail
        volumes:
            - '$PWD/data/letsencrypt:/etc/letsencrypt'
            - '$PWD/data/haproxy.cfg:/etc/haproxy/haproxy.cfg'
        networks:
            - lbnet
        ports:
            - '80:80'
            - '443:443'
        image: 'tomdess/haproxy-certbot:latest'
    nginx:
        container_name: www
        networks:
            - lbnet
        image: nginx

networks:
  lbnet:
  

$ docker-compose up -d

```

### Customizing Haproxy

You will almost certainly want to create an image `FROM` this image or
mount your `haproxy.cfg` at `/etc/haproxy/haproxy.cfg`.


    docker run [...] -v <override-conf-file>:/etc/haproxy/haproxy.cfg tomdess/haproxy-certbot:latest

The haproxy configuration provided file comes with the "resolver docker" directive to permit DNS runt-time resolution on backend hosts (see https://github.com/gesellix/docker-haproxy-network)

### Renewal cron job

Once a week a cron job check for expiring certificates with certbot agent and reload haproxy if a certificate is renewed. No containers restart needed.

### Credits

Most of ideas taken from https://github.com/BradJonesLLC/docker-haproxy-letsencrypt
