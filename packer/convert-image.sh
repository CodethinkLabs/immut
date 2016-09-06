#!/bin/bash

qemu-img convert -f qcow2 output-qemu/packer-qemu -O vdi output-qemu/packer-qemu.vdi
