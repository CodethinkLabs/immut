#!/bin/bash


#format markdown. This MUST be *before* scan-path! Line numbers will be weird
echo "source-filter=/usr/libexec/cgit/filters/about-formatting.sh" >> /etc/cgitrc

#Include gits path in cgitrc
echo "scan-path=/data" >> /etc/cgitrc

#Create example repositories if /data is empty
if ! [ "$(ls -A /data)" ]; then
    gits="foo bar baz"
    for reponame in $gits; do
	git init --bare /data/$reponame
        cp /data/$reponame/hooks/post-update.sample /data/$reponame/hooks/post-update
    done
fi

#fix ownership of git repos
chown -R apache:apache /data

#set variables
APACHE_LOCK_DIR="/var/lock/httpd"
APACHE_RUN_USER="apache"
APACHE_RUN_GROUP="apache"
APACHE_PID_FILE="/var/run/httpd/httpd.pid"
APACHE_RUN_DIR="/var/run/httpd"

#create directories if necessary
if ! [ -d /var/run/httpd ]; then mkdir /var/run/httpd;fi
if ! [ -d /var/lock/httpd ]; then mkdir /var/lock/httpd;fi

#run Apache
httpd -D FOREGROUND
