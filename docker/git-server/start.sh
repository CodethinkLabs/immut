#!/bin/bash

# Make it check sss before altfiles
sed -i -e 's/altfiles sss/sss altfiles/' /etc/nsswitch.conf

# Configure access rules in git-server.conf
if [ "x$PROJECT_NAME" != "x" ]; then
    sed -i -e "s/Require valid-user/Require unix-group $PROJECT_NAME/" /etc/httpd/conf.d/git-server.conf
fi

#Remove default apache configuration file for cgit
rm /etc/httpd/conf.d/cgit.conf

#Create folder for CGit cache
mkdir -p /var/cache/cgit
chown -R apache:apache /var/cache/cgit

#syntax highlighting. This MUST be *before* scan-path!
echo "source-filter=/usr/libexec/cgit/filters/syntax-highlighting.py" >> /etc/cgitrc

#add an 'about' tab and format the contents
echo "about-filter=/usr/libexec/cgit/filters/about-formatting.sh" >> /etc/cgitrc

#currently will only work for a file called 'README.md'; can add more options
echo "readme=:README.md" >> /etc/cgitrc

#Include gits path in cgitrc
echo "scan-path=/data/gitserver" >> /etc/cgitrc

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
