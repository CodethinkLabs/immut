#!/bin/bash

#fix ownership of git repos

chown -R apache:apache /opt/git

#set variables
APACHE_LOG_DIR="/var/log/httpd"
APACHE_LOCK_DIR="/var/lock/httpd"
APACHE_RUN_USER="apache"
APACHE_RUN_GROUP="apache"
APACHE_PID_FILE="/var/run/httpd/httpd.pid"
APACHE_RUN_DIR="/var/run/httpd"

#create directories if necessary
if ! [ -d /var/run/httpd ]; then mkdir /var/run/httpd;fi
if ! [ -d /var/log/httpd ]; then mkdir /var/log/httpd;fi
if ! [ -d /var/lock/httpd ]; then mkdir /var/lock/httpd;fi

#run Apache
httpd -D FOREGROUND
