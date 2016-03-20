FROM php:7.0-cli

MAINTAINER "Zak Henry" <zak.henry@gmail.com>

RUN mkdir -p /data
VOLUME ["/data"]


#add custom ppa for git so that we get the latest version
RUN printf "deb http://ppa.launchpad.net/git-core/ppa/ubuntu precise main\ndeb-src http://ppa.launchpad.net/git-core/ppa/ubuntu precise main" >> /etc/apt/sources.list.d/git-core.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E1DF1F24  && \
    apt-get update || true


# Then install node with:
RUN apt-get install -y curl && \
    curl -sL https://deb.nodesource.com/setup_5.x | bash - && \
    apt-get install -y --force-yes \
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
    libmcrypt-dev \
    libxml2-dev

RUN docker-php-ext-install mcrypt pdo_pgsql mbstring pdo_mysql sockets opcache soap

ENV XDEBUG_VERSION xdebug-2.4.0rc3
RUN cd /tmp && \
    curl -sL -o xdebug.tgz http://xdebug.org/files/$XDEBUG_VERSION.tgz && \
    tar -xvzf xdebug.tgz && \
    cd xdebug* && \
    phpize && \
    ./configure && make && \
    cp modules/xdebug.so /usr/local/lib/php/extensions/no-debug-non-zts-20151012 && \
    echo 'zend_extension = /usr/local/lib/php/extensions/no-debug-non-zts-20151012/xdebug.so' >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
    rm -rf /tmp/xdebug*

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

# Install composer
RUN curl -sS# https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer

# Configure php
ADD config/memory.ini /opt/etc/memory.ini
ADD config/xdebug.ini /opt/etc/xdebug.ini

RUN sed -i "s|%data-root%|${DATA_ROOT:-/data}|" /opt/etc/xdebug.ini

RUN cat /opt/etc/memory.ini >> /usr/local/etc/php/conf.d/memory.ini && \
    cat /opt/etc/xdebug.ini >> /usr/local/etc/php/conf.d/xdebug.ini


# Clean everything
RUN npm config set tmp /root/.tmp && \
    npm cache clean && \
    apt-get autoremove -yqq && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    npm cache clear

RUN printf "#!/bin/bash\nmv /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini.disabled" >> /usr/local/bin/xdebug-off
RUN printf "#!/bin/bash\nmv /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini.disabled /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini" >> /usr/local/bin/xdebug-on
RUN chmod +x /usr/local/bin/xdebug-off
RUN chmod +x /usr/local/bin/xdebug-on

RUN mv /usr/bin/composer /usr/bin/composer-actual
RUN printf '#!/bin/bash\nxdebug-off;/usr/bin/composer-actual "$@";xdebug-on' >> /usr/bin/composer && chmod +x /usr/bin/composer


# Verify all install locations
RUN which npm
RUN which bower
RUN which gulp
RUN which php
RUN which composer
RUN which phantomjs
RUN which git
# Get all versions
RUN node --version && \
    npm --version && \
    bower --version && \
    gulp --version && \
    php --version && \
    composer --version && \
    phantomjs --version && \
    git --version

WORKDIR /data

ENTRYPOINT ["/bin/bash", "-c"]
CMD ["ls", "-alh", "/data"]
