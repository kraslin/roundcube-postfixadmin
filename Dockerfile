FROM alpine:latest

LABEL description "Roundcube-Postfix is a simple, modern & fast webmail client combined with an administrative Postfixadmin webportal to manage postfix accounts." \
      maintainer="Malfurious <jmay9990@gmail.com>"

#
# Arguments and which Roundcube plugins we'll need
#
ARG ROUND_VERSION=1.5.6
ARG POST_VERSION=v4.0.1
ENV PLUGINS="'archive', 'zipdownload', 'password','enigma','emoticons','filesystem_attachments','managesieve','identity_smtp','calendar','contextmenu','markasjunk2','persistent_login'"

#
# Replace custom nginx-php base image
#
RUN apk update && apk upgrade && \
	apk add nginx gnupg tini composer git su-exec supervisor \
	php83-bz2 php83-calendar php83-common php83-ctype php83-curl \
	php83-exif php83-fileinfo php83-fpm php83-gd php83-gettext php83-iconv php83-pecl-imagick php83-imap \
	php83-intl php83-json php83-ldap php83-mbstring php83-mysqli php83-openssl \
	php83-pdo php83-pdo_mysql php83-pear php83-pspell php83-session php83-xmlwriter \
	php83-simplexml php83-sockets php83-tokenizer php83-xsl php83-zip php83-pecl-mcrypt

#
# Things we need to download
#
RUN cd /tmp && \
	wget https://github.com/roundcube/roundcubemail/releases/download/${ROUND_VERSION}/roundcubemail-${ROUND_VERSION}-complete.tar.gz && \
	wget https://github.com/postfixadmin/postfixadmin/archive/refs/tags/${POST_VERSION}.tar.gz

#
# Postfix Admin
#
RUN mkdir /postfixadmin && tar xvf /tmp/v${POST_VERSION}.tar.gz -C /postfixadmin && \
	mv /postfixadmin/postfixadmin-${POST_VERSION}/* /postfixadmin && \
	rm -rf /postfixadmin/postfixadmin-${POST_VERSION}

#
# Roundcube
#
RUN mkdir /roundcube && tar -xzf /tmp/roundcubemail-${ROUND_VERSION}-complete.tar.gz --strip 1 -C /roundcube && \
	mv /roundcube/config/config.inc.php.sample /roundcube/config/config.inc.php && \
	mv /roundcube/composer.json-dist /roundcube/composer.json && \
	cd /roundcube && composer install --no-dev && composer require sabre/vobject 3.3.3

#
# Roundcube Plugins
#
RUN cd /roundcube/plugins && \
	git clone https://github.com/elm/Roundcube-SMTP-per-Identity-Plugin.git identity_smtp && \
	git clone https://github.com/JohnDoh/Roundcube-Plugin-Context-Menu.git contextmenu && \
	git clone https://github.com/JohnDoh/Roundcube-Plugin-Mark-as-Junk-2.git markasjunk2 && \
	git clone https://github.com/mfreiholz/persistent_login.git persistent_login

#
# Configure Roundcube plugins
#
RUN mv /roundcube/plugins/password/config.inc.php.dist /roundcube/plugins/password/config.inc.php && \
	mv /roundcube/plugins/enigma/config.inc.php.dist /roundcube/plugins/enigma/config.inc.php && \
	mv /roundcube/plugins/persistent_login/config.inc.php.dist /roundcube/plugins/persistent_login/config.inc.php

#
# Activate plugins
#
RUN echo "\$config['plugins'] = [${PLUGINS}];" >> /roundcube/config/config.inc.php

#
# Web file permissions
#
RUN find /postfixadmin -type d -exec chmod 755 {} \; && \
	find /postfixadmin -type f -exec chmod 644 {} \; && \
	find /roundcube -type d -exec chmod 755 {} \; && \
	find /roundcube -type f -exec chmod 644 {} \;

#
# Whatever Enigma is
#
RUN mkdir /enigma
VOLUME /enigma

#
# Things the original Dockerfile copied
#
COPY rootfs /
#COPY mysql.initial.sql /roundcube/SQL

RUN mkdir -p /run/nginx && chown nginx:nginx /run/nginx

RUN sed -r -i /etc/php83/php-fpm.d/www.conf \
	-e 's@(listen\s*=\s*).+$@\1/var/run/php-fpm.sock@' \
	-e 's@;?(listen.mode\s*=\s*).+$@\10666@' \
	-e 's@;?(listen.acl_users\s*=\s*).+$@\1nginx@'

#
# Cleanup
#
RUN rm -rf /tmp/* /var/cache/apk/* /root/.gnupg

#
# Port 8080 = Postfix Admin
# Port 8888 = Roundcube
#
EXPOSE 8888 8080

CMD ["tini", "--", "/run.sh"]

LABEL PostfixAdminVersion="${POST_VERSION}"
LABEL RoundCubeVersion="${ROUND_VERSION}"
