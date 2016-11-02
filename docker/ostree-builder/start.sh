#!/bin/bash

set -e
set -x

mkdir -p /home/working
git clone https://github.com/CentOS/sig-atomic-buildscripts /home/working/sig-atomic-buildscripts
git clone https://git.fedorahosted.org/git/fedora-atomic.git -b f23 /home/working/fedora-atomic

ostree --repo=/data/repo init --mode=archive-z2

cd /home/working/fedora-atomic/
curl -o fedora-23-updates.repo https://git.fedorahosted.org/cgit/fedora-repos.git/plain/fedora-updates.repo?h=f23
sed -i -e 's/\$releasever/23/g' fedora-23-updates.repo
cp /workdir/*.json /home/working/fedora-atomic/
cp /workdir/treecompose-var-post.sh /home/working/fedora-atomic/
rpm-ostree compose tree --repo=/data/repo /home/working/fedora-atomic/fedora-atomic-yarn-runner.json
rpm-ostree compose tree --repo=/data/repo /home/working/fedora-atomic/fedora-atomic-update-tree.json
rpm-ostree compose tree --repo=/data/repo /home/working/fedora-atomic/fedora-atomic-haproxy.json
rpm-ostree compose tree --repo=/data/repo /home/working/fedora-atomic/fedora-atomic-gitserver.json

#Create /etc -> /usr/etc symlink
cd /workdir
ostree --repo=/data/repo checkout -U fedora-atomic/f23/x86_64/docker-gitserver gitserver
mv gitserver/usr/etc gitserver/etc            # Put /etc in the right place
rm -r gitserver/usr/var/lib                   # Remove /usr/var/lib to avoid conflicts
rm -r `find gitserver/usr/var -type d -empty` # Remove empty folders from /usr/var
mv gitserver/usr/var/* gitserver/var/         # Move /usr/var contents to /var
rm -r gitserver/usr/var                       # Remove what's left from /usr/var
ostree --repo=/data/repo commit -b fedora-atomic/f23/x86_64/docker-gitserver --link-checkout-speedup gitserver

rm -rf /data/repo/uncompressed-objects-cache
