FROM symfony-app-base AS symfony-app

ENV APP_ENV dev

COPY infra/${APP_ENV}/supervisord/supervisord.conf /etc/supervisord.conf

COPY infra/${APP_ENV}/supervisord/entrypoint /usr/local/bin/entrypoint

RUN chmod +x /usr/local/bin/entrypoint

RUN addgroup -g 1000 user-app_group

RUN adduser -u 1000 -G user-app_group -h /home/user-app -D user-app

WORKDIR /var/www/app

ENTRYPOINT ["supervisord", "--configuration", "/etc/supervisord.conf", "--nodaemon"]
