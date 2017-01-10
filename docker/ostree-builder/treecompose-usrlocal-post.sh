#!/usr/bin/env bash

set -e
set -x

# Fix ruby paths for the ec2-ami-tools
sed -i -e 's#^ruby#ruby -I/usr/lib/ruby/site_ruby#' /usr/local/ec2/amitools/*
# Move tools to /usr because /var is emptied in Atomic
mv /usr/local/ec2/amitools/* /usr/bin
# Re-create symlinks instead of moving the installed ones in /var
tools="ec2-ami-tools-version \
       ec2-bundle-image \
       ec2-bundle-vol \
       ec2-delete-bundle \
       ec2-download-bundle \
       ec2-migrate-bundle \
       ec2-migrate-manifest \
       ec2-unbundle \
       ec2-upload-bundle"

for name in $tools; do
    ln -s /usr/bin/$(echo $name| cut -d \- -f2- | sed -e 's/-//g') /usr/bin/$name
done


# See: https://bugzilla.redhat.com/show_bug.cgi?id=1051816
KEEPLANG=en_US
find /usr/share/locale -mindepth  1 -maxdepth 1 -type d -not -name "${KEEPLANG}" -exec rm -rf {} +
localedef --list-archive | grep -a -v ^"${KEEPLANG}" | xargs localedef --delete-from-archive
mv -f /usr/lib/locale/locale-archive /usr/lib/locale/locale-archive.tmpl
build-locale-archive
