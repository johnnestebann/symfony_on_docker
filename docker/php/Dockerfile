FROM php:8.0-fpm-alpine AS symfony-app-common

RUN apk add --no-cache \
		acl \
		fcgi \
		file \
		gettext \
        openssl \
		git \
		gnu-libiconv \
	;

ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so

RUN set -eux; \
	apk add --no-cache --virtual .build-deps \
		$PHPIZE_DEPS \
		icu-dev \
		libzip-dev \
		postgresql-dev \
		zlib-dev \
	; \
	\
	docker-php-ext-configure zip; \
	docker-php-ext-install -j$(nproc) \
		intl \
		pdo_pgsql \
		zip \
	; \
	pecl install \
		apcu-5.1.20 \
	; \
	pecl clear-cache; \
	docker-php-ext-enable \
		apcu \
		opcache \
	; \
	\
	runDeps="$( \
		scanelf --needed --nobanner --format '%n#p' --recursive /usr/local/lib/php/extensions \
			| tr ',' '\n' \
			| sort -u \
			| awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
	)"; \
	apk add --no-cache --virtual .api-phpexts-rundeps $runDeps; \
	\
	apk del .build-deps

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

ENV COMPOSER_ALLOW_SUPERUSER=1

ENV PATH="${PATH}:/root/.composer/vendor/bin"

RUN addgroup -g 1000 symfony_app_group

RUN adduser -u 1000 -G symfony_app_group -h /home/symfony_app_user -D symfony_app_user

USER symfony_app_user

WORKDIR /var/www/app