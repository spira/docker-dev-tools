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
    gulp bower

# Then install phantomjs with :
ENV PHANTOM_JS_VERSION 1.9.8-linux-x86_64

# Install apt deps
RUN apt-get install -y \
    git \
    libfreetype6 \
    libfontconfig
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
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer


# create dir to save phantom
RUN mkdir -p /opt/phantomjs && \
    cd /opt/phantomjs

# download the file (this will take time)
RUN curl -LO https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-$PHANTOM_JS_VERSION.tar.bz2
RUN tar xjf phantomjs-$PHANTOM_JS_VERSION.tar.bz2

# symlink to /usr/bin and check install
RUN ln -s /opt/phantomjs/phantomjs-$PHANTOM_JS_VERSION/bin/phantomjs /usr/bin/phantomjs && \
    rm phantomjs-$PHANTOM_JS_VERSION.tar.bz2

# Install phpunit globally
RUN mkdir -p /opt/phpunit && \
    cd /opt/phpunit

RUN wget https://phar.phpunit.de/phpunit.phar
RUN chmod +x phpunit.phar && \
    ls -s /opt/phpunit.phar /usr/bin/phpunit

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
RUN which gulp bower hhvm npm composer phantomjs
# Get all versions
RUN npm --version && \
    bower --version && \
    gulp --version && \
    phantomjs --version && \
    hhvm --version && \
    composer --version

WORKDIR /data

ENTRYPOINT ["/bin/bash", "-c"]
CMD ["ls", "-alh", "/data"]