# Git server from docker

A lightweight Git Server in Docker, adapted from <https://github.com/jkarlosb/git-server-docker>

### Basic Usage

How to run the container in port 2222 with two volumes, keys volume for public keys and repos volume for git repositories:

    $ sudo docker run -d -p 2222:22 -v `pwd`/keys:/git-server/keys -v `pwd`/repos:/git-server/repos gitserver

How check that container works (you must to have a key):

    $ ssh git@localhost -p 2222
    ...
    INTERACTIVE SHELL ACCESS DISABLED!!
    ...

How clone a repository:

    $ git clone ssh://git@localhost:2222/git-server/repos/myrepo.git

### To make the container use SSSD configuration from the host you have to

*   Install packages

        $ sudo dnf -y install sssd-common sssd-proxy

*   Create a PAM service for the container.

        # cat /etc/pam.d/sss_proxy
        auth required pam_unix.so
        account required pam_unix.so
        password required pam_unix.so
        session required pam_unix.so

*   Create SSSD config file, /etc/sssd/sssd.conf (Please note that the permissions
    must be 0600 and the file must be owned by root:root)

        # cat /etc/sssd/sssd.conf
        [sssd]
        services = nss, pam
        config_file_version = 2
        domains = proxy
        [nss]
        [pam]
        [domain/proxy]
        id_provider = proxy
        # The proxy provider will look into /etc/passwd for user info
        proxy_lib_name = files
        # The proxy provider will authenticate against /etc/pam.d/sss_proxy
        proxy_pam_target = sss_proxy

*   Start sssd

        systemctl start sssd

*   Run the container

        $ sudo docker run -d -p 2222:22 -v `pwd`/keys:/git-server/keys -v `pwd`/repos:/git-server/repos -v=/var/lib/sss/pipes/:/var/lib/sss/pipes/:rw gitserver


If instead of running the container you just want to test if SSSD would work
in the container you can:

*   Create an user in the host that you know won't be available in the container

        $ sudo adduser awesomeuser

*   Execute Shell in the container in interactive mode

        $ sudo docker run -i -t -v=/var/lib/sss/pipes/:/var/lib/sss/pipes/:rw  gitserver /bin/sh

*   Check the user from the container

        $ getent passwd -s sss awesomeuser
        awesomeuser:*:1001:1001::/home/awesomeuser:/bin/bash

### Build Image

How to make the image:

    $ docker build -t gitserver .
