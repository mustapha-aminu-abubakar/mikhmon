FROM php:7.4-fpm-alpine
RUN apk add --no-cache nginx supervisor
COPY nginx.conf /etc/nginx/nginx.conf
RUN sed -i 's/listen = 9000/listen = 127.0.0.1:9000/' /usr/local/etc/php-fpm.d/www.conf && \
    sed -i 's/user = www-data/user = nginx/' /usr/local/etc/php-fpm.d/www.conf && \
    sed -i 's/group = www-data/group = nginx/' /usr/local/etc/php-fpm.d/www.conf
COPY supervisord.conf /etc/supervisor.conf
COPY . /var/www/
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
RUN chown -R nginx:nginx /var/www/ && rm -f /var/www/docker-compose.yml
EXPOSE 80
CMD ["/entrypoint.sh"]
