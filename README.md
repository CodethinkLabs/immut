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
3. Virtual Box (and/or qemu)

## Build

Currently the project consists of a project atomic virtual machine image with SSSD running on the host. 
SSSD provides authentication to running docker containers. The build depends on the creation of a docker 
image to perform updates.

To build the project run:

    packer build rpmostree-update.json
	packer build  fedora-atomic-24.json

This will output all images we currently support. In order to build a single image use the -only packer argument.

for Virtual Box:

    packer-io build -only virtualbox fedora-atomic-24.json

for Qemu:

	packer-io build -only qemu fedora-atomic-24.json