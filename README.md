# Immut

## Overview

This project is a work in progress automating the creation of immutable
infrastructure.

### Goals

1. Automate as much of the infrastructure setup as possible.
2. Provide auditable configuration files.
3. Store all infrastructure definitions and configuration in git.

## Prerequisites

1. Packer (https://github.com/mitchellh/packer)
2. Docker
3. Virtual Box and/or Qemu
4. Kernel >= 4.6 (anything > 4 may work, but this is untested)

## Build

Currently the project consists of a project atomic virtual machine image with
SSSD running on the host. 

SSSD provides authentication to running docker containers. The build depends
on the creation of an Ostree repository creation to perform an update of the
Atomic host and to use for the Docker containers.

We recommend that you do not build this in a virtual environment, as nested
virtualization will be slow.

First of all you need to build an Ostree repository. Go to the
`immut/packer` directory and run:

    packer build rpmostree-update.json

Now you have an Ostree repository in compressed in `immut/packer/files/repo.zip`
with all the filesystems needed to make the system work.

To build the VM, cd into the `immut/packer` directory (if you are not already
there from the previous step) and run:

    sudo unzip files/repo.zip -d files
    packer build fedora-atomic-24.json

> Note: This will output all images we currently support. In order to build
> only one of them see below:


In order to build a single image use the `-only` packer argument, eg:

*   to build only a VirtualBox image (output image file in `immut/packer/output-virtualbox`):

        packer build -only virtualbox fedora-atomic-24.json

*   to build only a Qemu image (output image file in `immut/packer/output-qemu`):

    Add `"headless": "true",` to the qemu config in fedora-atomic-24.json
    This will be the default in the future; it is not the default yet
    as it is harder to develop in headless mode.

        packer build -only qemu fedora-atomic-24.json

Next, to make the Qemu image testable in VirtualBox, cd into the
output-qemu directory and convert it using:

    qemu-img convert -f qcow2 packer-qemu -O vdi packer-qemu.vdi

---

## Set Up

Once you have an image, cd into the immut/cloud-init-iso directory and run
the script. This will create an iso that will run the docker containers.

Now, create a virtual machine. If using the qemu build, do things the usual
way and use the image you created with packer for the hard disk file. If using
the VirtualBox build, you should instead import the ovf file to create the
VM:

In VirtualBox:

  * file > import appliance
  * select the .ovf from the immut/packer/output-virtualbox directory
  * click 'import'

That should create a VM.

Attach the iso to the optical drive (and make sure it's not
treated as a live CD).

Add a VirtualBox host-only network to your VM:

* file > preferences > network

* (add it)

* click the screwdriver

* go to the DCHP server tab:

  * change server address to match adapter address, but with 2
    at the end instead of 1

  * change server mask to 255.255.255.0

  * change lower address to match the adapter address but with 
    110 at the end instead of 1

  * change upper adress to match the adapter address but with 200
    at the end instead of 1

* right click your vm > settings > network

* enable adapter 2 and attach it to a host-only adapter

This will ensure the VM has a visible IPV4 address.

---

## Run

Start the VM! Use the Fedora 23 default, with login username 'root' with
password 'atomic'.

Once you are logged in, running `docker ps` should return some information.

On the VM, create a new user, eg:

    adduser catscatscats
    passwd catscatscats

On the VM, run `ip addr` to get its IP address. There will be a few; the
relevant one should have a name like 'enp0s8' and look fairly standard
(ie: start with 192.168...)

Now, on your host, you can now run something like: 

    git clone http://gitserver.p1.$VM-IP-ADDRESS.xip.io/git/foo

to get a repo from your new git server. You should be able to add, commit
and push changes. If you browse to:

  http://gitserver.p1.$VM-IP-ADDRESS.xip.io/cgit/

You should be able to see a cgit instance, containing your changes.
