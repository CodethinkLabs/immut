# Ostree builder

An ostree builder using docker.

# Build the container

    $ docker build . -t ostree-builder

# To build the ostree repo using the container

    $ mkdir data
    $ docker run --privileged -v `pwd`/data:/data:rw ostree-builder

The final ostree repo will be in the `data` folder.
