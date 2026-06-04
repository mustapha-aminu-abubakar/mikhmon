FROM php:7.4-fpm-alpine
RUN apk add --no-cache nginx supervisor
COPY nginx.conf /etc/nginx/conf.d/default.conf
RUN sed -i 's/fastcgi_pass php_7_4:9000;/fastcgi_pass 127.0.0.1:9000;/' /etc/nginx/conf.d/default.conf
COPY supervisord.conf /etc/supervisor.conf
COPY . /var/www/
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh && rm -f /var/www/docker-compose.yml
EXPOSE 80
CMD ["/entrypoint.sh"]
