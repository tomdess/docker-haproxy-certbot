# Dockerized HAProxy with Let's Encrypt automatic certificate renewal capabilities

This container provides a HAProxy 1.9 application with Let's Encrypt certificates
generated at startup, as well as renewed (if necessary) once a week.

## Usage

```
docker run \
    -e CERTS=my.domain,my.other.domain \
    -e EMAIL=my.email@my.domain \
    -v /etc/letsencrypt:/etc/letsencrypt \
    -p 80:80 -p 443:443 \
    tomdess/docker-haproxy-letsencrypt
```


#### Customizing Haproxy

You will almost certainly want to create an image `FROM` this image or
mount your `haproxy.cfg` at `/etc/haproxy/haproxy.cfg`.


    docker run [...] -v <override-conf-file>:/etc/haproxy/haproxy.cfg tomdess/docker-haproxy-letsencrypt

