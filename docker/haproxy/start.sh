#!/bin/bash

if [ -e /data/haproxy.cfg ]; then
    cp /data/haproxy.cfg /etc/haproxy/haproxy.cfg
fi

haproxy-systemd-wrapper -f /etc/haproxy/haproxy.cfg -p /run/haproxy.pid
