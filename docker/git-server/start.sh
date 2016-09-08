#!/bin/sh

cd /home/git

# Copy public keys from the keys folder to authorized_keys
if [ "$(ls -A /git-server/keys/)" ]; then
  cat /git-server/keys/*.pub | tee .ssh/authorized_keys
  chown -R git:git .ssh
  chmod 700 .ssh
  chmod -R 600 .ssh/*
fi

/usr/sbin/sshd -D
