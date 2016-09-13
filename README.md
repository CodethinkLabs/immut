# Immut

## Overview

This is project is a work in progress automating the creation of immutable infrastructure.

### Goals

1. Automate as much of the infrastructure setup as possible.
2. Provide auditable configuration files.
3. Store all infrastructure definitions and configuration in git.

## Prerequisites

1. Packer (https://github.com/mitchellh/packer)
2. Docker
2. Virtual Box (We also have a qemu builder branch, see: craiggriffiths/qemu_builder)

## Build

Currently the project consists of a project atomic virtual machine image with SSSD running on the host. 
SSSD provides authentication to running docker containers. The build depends on the creation of a docker 
image to perform updates.

To build the project run:

    packer build rpmostree-update.json (Requires root if your user account is not part of the docker group.)
	packer build fedora-atomic-24.json