FROM php:7.0-cli

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
    build-essential \
    libfreetype6 \
    libfontconfig \
    libpq-dev \
    libicu52 \
    libjpeg-dev \
    libfreetype6 \
    libfontconfig \
    unzip \
    vim \
    libmcrypt-dev

RUN docker-php-ext-install mcrypt pdo_pgsql mbstring pdo_mysql

RUN which npm

# Install npm global dependencies
RUN npm install -g \
    gulp bower

# Then install phantomjs with :
ENV PHANTOM_JS_VERSION 2.0.0-debian-x86_64

# create dir to save phantom
RUN mkdir -p /opt/phantomjs
WORKDIR /opt/phantomjs


# download the file (this will take time)
RUN mkdir -p /opt/phantomjs/phantomjs-$PHANTOM_JS_VERSION/bin
RUN curl -sL -o /opt/phantomjs/phantomjs-$PHANTOM_JS_VERSION.zip https://github.com/jakemauer/phantomjs/releases/download/2.0.0-debian-bin/phantomjs-$PHANTOM_JS_VERSION.zip
RUN unzip /opt/phantomjs/phantomjs-$PHANTOM_JS_VERSION.zip -d /opt/phantomjs/phantomjs-$PHANTOM_JS_VERSION/bin
RUN rm -f /opt/phantomjs/phantomjs-$PHANTOM_JS_VERSION.zip
RUN ln -s /opt/phantomjs/phantomjs-$PHANTOM_JS_VERSION/bin/phantomjs /usr/bin/phantomjs

# @todo restore the official bitbucket.org/ariya version when they release phantom2
# RUN curl -LO https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-$PHANTOM_JS_VERSION.tar.bz2
# RUN tar xjf phantomjs-$PHANTOM_JS_VERSION.tar.bz2

# symlink to /usr/bin and check install
# RUN ln -s /opt/phantomjs/phantomjs-$PHANTOM_JS_VERSION/bin/phantomjs /usr/bin/phantomjs && \
#    rm phantomjs-$PHANTOM_JS_VERSION.tar.bz2

RUN which phantomjs && phantomjs --version

# Install apt deps
RUN apt-get update -y && \
    apt-get install -y \
    curl \
    git \
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

# Clean everything
RUN npm config set tmp /root/.tmp && \
    npm cache clean && \
    apt-get autoremove -yqq && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    npm cache clear

# Verify all install locations
RUN which npm
RUN which bower
RUN which gulp
RUN which php
RUN which composer
RUN which phantomjs
# Get all versions
RUN npm --version && \
    bower --version && \
    gulp --version && \
    php --version && \
    composer --version && \
    phantomjs --version

WORKDIR /data

ENTRYPOINT ["/bin/bash", "-c"]
CMD ["ls", "-alh", "/data"]