FROM estebanmatias92/hhvm:3.5-fastcgi

MAINTAINER "Zak Henry" <zak.henry@gmail.com>

RUN mkdir -p /data
VOLUME ["/data"]

RUN apt-get update

# Then install node with:
RUN apt-get install -y curl && \
    curl -sL https://deb.nodesource.com/setup_0.12 | bash - && \
    apt-get install -y \
    nodejs \
    git \
    bzip2 \
    build-essential

RUN which npm

# Install npm global dependencies
RUN npm install -g \
    gulp bower phantomjs2

# Install apt deps
RUN apt-get install -y \
    git \
    libfreetype6 \
    libfontconfig \
    php5-cli \
    php5-mcrypt \
    php5-mongo \
    php5-mssql \
    php5-mysqlnd \
    php5-pgsql \
    php5-redis \
    php5-sqlite \
    php5-gd

# Install composer
RUN curl -sS# https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer

# Install phpunit globally
RUN mkdir -p /opt/phpunit && \
    cd /opt/phpunit

RUN curl -LO# https://phar.phpunit.de/phpunit.phar
RUN chmod +x phpunit.phar && \
    ln -s /opt/phpunit.phar /usr/bin/phpunit

# Configure hhvm
ADD config/xdebug.ini /opt/etc/xdebug.ini
ADD config/errors.ini /opt/etc/errors.ini

RUN cat /opt/etc/xdebug.ini >> /etc/hhvm/server.ini && \
    cat /opt/etc/errors.ini >> /etc/hhvm/server.ini && \
    cat /opt/etc/xdebug.ini >> /etc/hhvm/php.ini && \
    cat /opt/etc/errors.ini >> /etc/hhvm/php.ini

# Clear apt-get data
RUN apt-get remove --purge curl -y && \
    apt-get clean

# Clean everything
RUN npm config set tmp /root/.tmp && \
    npm cache clean && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    npm cache clear

# Verify all install locations
RUN which npm
RUN which bower
RUN which gulp
RUN which hhvm
RUN which phpunit
RUN which composer
RUN which phantomjs
# Get all versions
RUN npm --version && \
    bower --version && \
    gulp --version && \
    hhvm --version && \
    phpunit --version && \
    composer --version && \
    phantomjs --version

WORKDIR /data

ENTRYPOINT ["/bin/bash", "-c"]
CMD ["ls", "-alh", "/data"]