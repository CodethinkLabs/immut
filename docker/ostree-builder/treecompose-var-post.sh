#!/usr/bin/env bash

set -e
set -x

mkdir /usr/var
cp -r /var/* /usr/var || true # Ignore errors
