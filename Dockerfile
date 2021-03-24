FROM php:7-alpine

# Install extensions
RUN apk update \
    && apk upgrade \
    && apk add --no-cache \
        freetype-dev \
        libpng-dev \
        jpeg-dev \
        libjpeg-turbo-dev

RUN apk add php7-gd php7-mysqli php7-zlib php7-curl

RUN docker-php-ext-configure gd --with-freetype --with-jpeg

RUN NUMPROC=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) \
    && docker-php-ext-install -j${NUMPROC} gd

WORKDIR /var/www
COPY . /var/www

EXPOSE 9000
CMD ["php-fpm"]