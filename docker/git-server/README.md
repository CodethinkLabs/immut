# Git server from docker

A git server in Docker served with Apache and using PAM authentication

### Basic Usage

How to run the container in port 8000 with a git's volume:

    $ sudo docker run -i -t  -p 8000:80 -v=/path/to/gits/:/opt/git/:rw gitserver-apache


How to clone a repository (you must have a configured PAM user)

    $ git clone http://<docker-host-ip>:8000/git/<repo-name> cloned-repo
    Cloning into 'cloned-repo'...
    Username for 'http://<docker-host-ip>:8000':
    ...

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

        $ sudo docker run -d  -p 8000:80 -v=/var/lib/sss/pipes/:/var/lib/sss/pipes/:rw  -v=/path/to/gits/:/opt/git/:rw gitserver-apache 

If instead of running the container you just want to test if SSSD would work
in the container you can:

*   Create an user in the host that you know won't be available in the container

        $ sudo adduser awesomeuser

*   Execute Shell in the container in interactive mode

        $ sudo docker run -i -t -v=/var/lib/sss/pipes/:/var/lib/sss/pipes/:rw  gitserver /bin/sh

*   Check the user from the container

        $ getent passwd -s sss awesomeuser
        awesomeuser:*:1001:1001::/home/awesomeuser:/bin/bash

### Logging

Logs will be sent to syslog using a `GIT-SERVER` tag. If you want to be
able to access them from the host make sure you mount `/dev/log` into the
container.

    $ docker run -v=/dev/log:/dev/log .....

### Build Image

How to make the image:

    $ docker build -t gitserver-apache .
