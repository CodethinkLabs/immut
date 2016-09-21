#!/bin/bash

. /etc/sysconfig/haproxy
haproxy-systemd-wrapper -f /etc/haproxy/haproxy.cfg -p /run/haproxy.pid $OPTIONS
