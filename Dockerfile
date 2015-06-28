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
    build-essential \
    libfreetype6 \
    libfontconfig

RUN which npm

# Install npm global dependencies
RUN npm install -g \
    gulp bower



# Dependencies we just need for building phantomjs
ENV buildDependencies\
  wget unzip python build-essential g++ flex bison gperf\
  ruby perl libsqlite3-dev libssl-dev libpng-dev

# Dependencies we need for running phantomjs
ENV phantomJSDependencies\
  libicu-dev libfontconfig1-dev libjpeg-dev libfreetype6 openssl

# Installing phantomjs
# Installing dependencies
RUN apt-get install -fyqq ${buildDependencies} ${phantomJSDependencies}
# pulling source

# create dir to save phantom
RUN mkdir -p /opt/phantomjs && \
    cd /opt/phantomjs

RUN wget https://github.com/ariya/phantomjs/archive/2.0.zip -O phantomjs-2.0.0-source.zip
RUN unzip -qq phantomjs-2.0.0-source.zip
RUN rm -rf /opt/phantomjs/phantomjs-2.0.0-source.zip
RUN ls -al && cd phantomjs-2.0/

RUN ./build.sh --jobs 1 --confirm --silent
# Removing everything but the binary
RUN ls -A | grep -v bin | xargs rm -rf
# Symlink phantom so that we are able to run `phantomjs`
RUN ln -s /opt/phantomjs/phantomjs-2.0/bin/phantomjs /usr/local/share/phantomjs \
    &&  ln -s /opt/phantomjs/phantomjs-2.0/bin/phantomjs /usr/local/bin/phantomjs \
    &&  ln -s /opt/phantomjs/phantomjs-2.0/bin/phantomjs /usr/bin/phantomjs
# Removing build dependencies, clean temporary files
RUN apt-get purge -yqq ${buildDependencies} \
    &&  apt-get autoremove -yqq \
    &&  apt-get clean \
    &&  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
# Checking if phantom works
RUN phantomjs -v

# Install apt deps
RUN apt-get install -y \
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