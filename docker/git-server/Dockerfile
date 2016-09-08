FROM fedora:24

RUN dnf -y update && dnf clean all
RUN dnf -y install openssh-server git && dnf clean all

# Generate server keys
RUN ssh-keygen -A

WORKDIR /git-server/

RUN mkdir /git-server/keys
RUN adduser -s /usr/bin/git-shell git
RUN echo git:12345 | chpasswd
RUN mkdir /home/git/.ssh

# This is a login shell for SSH accounts to provide restricted Git access.
# It permits execution only of server-side Git commands implementing the
# pull/push functionality, plus custom commands present in a subdirectory
# named git-shell-commands in the user’s home directory.
# More info: https://git-scm.com/docs/git-shell
COPY git-shell-commands /home/git/git-shell-commands

# Disable ssh by password
COPY sshd_config /etc/ssh/sshd_config
COPY start.sh start.sh

# Install tools needed for
RUN dnf -y install sssd-client
COPY sss_test /etc/pam.d/sss_test


# Configure port and program to start
EXPOSE 22
CMD ["sh", "start.sh"]
