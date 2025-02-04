FROM php:7.1-alpine


ENV KODEXPLORER_VERSION=4.39
ENV KODEXPLORER_URL="https://github.com/kalcaddle/KodExplorer/archive/"$KODEXPLORER_VERSION".tar.gz"

RUN set -x \
  && mkdir -p /usr/src/kodexplorer \
  && apk --update --no-cache add wget bash \
  && wget -O /tmp/kodexplorer.tar.gz "$KODEXPLORER_URL" \
  && tar -xzf /tmp/kodexplorer.tar.gz -C /usr/src/kodexplorer/ --strip-components=1 \
  && rm -rf /tmp/*

RUN set -x \
  && apk add --no-cache --update \
        freetype libpng libjpeg-turbo \
        freetype-dev libpng-dev libjpeg-turbo-dev \
  && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
  && docker-php-ext-install -j "$(getconf _NPROCESSORS_ONLN)" gd \
  && apk del --no-cache freetype-dev libpng-dev libjpeg-turbo-dev

VOLUME /var/www/html

WORKDIR /var/www/html

COPY entrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD [ "php", "-S", "0000:80", "-t", "/var/www/html" ]
