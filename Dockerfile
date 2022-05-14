FROM alpine:latest

LABEL description "Roundcube-Postfix is a simple, modern & fast webmail client combined with an administrative Postfixadmin webportal to manage postfix accounts." \
      maintainer="Malfurious <jmay9990@gmail.com>"

#
# Arguments and which Roundcube plugins we'll need
#
ARG ROUND_VERSION=1.5.2
ARG POST_VERSION=3.3.11
ENV PLUGINS="'archive', 'zipdownload', 'password','enigma','emoticons','filesystem_attachments','managesieve','identity_smtp','calendar','contextmenu','markasjunk2','tasklist','persistent_login'"

#
# Replace custom nginx-php base image
#
RUN apk update && apk upgrade && \
	apk add nginx gnupg tini composer git su-exec supervisor \
	php7-bz2 php7-calendar php7-common php7-ctype php7-curl \
	php7-exif php7-fileinfo php7-fpm php7-gd php7-gettext php7-iconv php7-pecl-imagick php7-imap \
	php7-intl php7-json php7-ldap php7-mbstring php7-mysqli php7-openssl \
	php7-pdo php7-pdo_mysql php7-pear php7-pspell php7-session \
	php7-simplexml php7-sockets php7-tokenizer php7-xsl php7-zip php7-mcrypt

#
# Things we need to download
#
RUN cd /tmp && \
	wget https://github.com/roundcube/roundcubemail/releases/download/${ROUND_VERSION}/roundcubemail-${ROUND_VERSION}-complete.tar.gz && \
	wget https://github.com/postfixadmin/postfixadmin/archive/refs/tags/postfixadmin-${POST_VERSION}.tar.gz && \
	git clone https://git.kolab.org/diffusion/RPK/roundcubemail-plugins-kolab.git

#
# Postfix Admin
#
RUN mkdir /postfixadmin && tar xvf /tmp/postfixadmin-${POST_VERSION}.tar.gz -C /postfixadmin && \
	mv /postfixadmin/postfixadmin-postfixadmin-${POST_VERSION}/* /postfixadmin && \
	rm -rf /postfixadmin/postfixadmin-postfixadmin-${POST_VERSION}

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
	cp -r /tmp/roundcubemail-plugins-kolab/plugins/calendar . && \
	cp -r /tmp/roundcubemail-plugins-kolab/plugins/libcalendaring . && \
	cp -r /tmp/roundcubemail-plugins-kolab/plugins/tasklist . && \
	git clone https://github.com/JohnDoh/Roundcube-Plugin-Context-Menu.git contextmenu && \
	git clone https://github.com/JohnDoh/Roundcube-Plugin-Mark-as-Junk-2.git markasjunk2 && \
	git clone https://github.com/mfreiholz/persistent_login.git persistent_login

#
# Configure Roundcube plugins
#
RUN mv /roundcube/plugins/password/config.inc.php.dist /roundcube/plugins/password/config.inc.php && \
	mv /roundcube/plugins/enigma/config.inc.php.dist /roundcube/plugins/enigma/config.inc.php && \
	mv /roundcube/plugins/tasklist/config.inc.php.dist /roundcube/plugins/tasklist/config.inc.php && \
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

RUN mkdir /run/nginx && chown nginx.nginx /run/nginx

RUN sed -r -i /etc/php7/php-fpm.d/www.conf \
	-e 's@(listen\s*=\s*).+$@\1/var/run/php-fpm.sock@' \
	-e 's@;?(listen.mode\s*=\s*).+$@\10666@' \
	-e 's@;?(listen.acl_users\s*=\s*).+$@\1nginx@'

#
# Cleanup
#
RUN rm -rf /tmp/* /var/cache/apk/* /root/.gnupg

#
# Port 8080 =
# Port 8888 = 
#
EXPOSE 8888 8080

CMD ["tini", "--", "/run.sh"]
