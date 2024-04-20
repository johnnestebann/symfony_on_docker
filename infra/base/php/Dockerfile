ARG PHP_VERSION="8.3-fpm-alpine3.19"
ARG COMPOSER_VERSION="2.7.2"

FROM composer:${COMPOSER_VERSION} as composer

FROM php:${PHP_VERSION} AS symfony-app-base

ENV NGINX_VERSION="1.24.0-r15"
ENV SUPERVISOR_VERSION="4.2.5-r4"
ENV APCU_VERSION="5.1.23"
ENV XDEBUG_VERSION="3.3.2"
ENV COMPOSER_ALLOW_SUPERUSER=1

RUN apk add --no-cache \
		acl \
		fcgi \
		file \
		gettext \
		git \
		gnu-libiconv \
        nginx=${NGINX_VERSION} \
        openssl \
        supervisor=${SUPERVISOR_VERSION} \
	;

RUN apk add --update linux-headers

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
		apcu-$APCU_VERSION \
        xdebug-$XDEBUG_VERSION \
	; \
	pecl clear-cache; \
	docker-php-ext-enable \
		apcu \
		opcache \
        xdebug \
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

COPY --from=composer /usr/bin/composer /usr/bin/composer
