#!/bin/bash

#Remove default apache configuration file for cgit
rm /etc/httpd/conf.d/cgit.conf

#Create folder for CGit cache
mkdir -p /var/cache/cgit
chown -R apache:apache /var/cache/cgit

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
APACHE_PID_FILE="/var/run/httpd/httpd.pid"
APACHE_RUN_DIR="/var/run/httpd"

#create directories if necessary

dirs="/var/run/httpd /var/lock/httpd /var/www/html /var/log/httpd /run/httpd"
for dir in $dirs; do
    if ! [ -d $dir ]; then mkdir -p $dir;fi
done

#run Apache
httpd -D FOREGROUND
