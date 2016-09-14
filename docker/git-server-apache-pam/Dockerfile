FROM fedora:24

RUN dnf -y update
RUN dnf -y install openssh-server git && dnf clean all
RUN dnf -y install httpd
RUN dnf -y install mod_authnz_pam
RUN dnf -y clean all

# Generate server keys
RUN ssh-keygen -A

WORKDIR /git-server/

RUN mkdir /opt/git
RUN adduser -s /usr/bin/git-shell git

# Configure SSSD PAM client
RUN dnf -y install sssd-client
COPY sss_git /etc/pam.d/sss_git

# Create Apache server for Git
COPY git-server.conf /etc/httpd/conf.d/git-server.conf


# Configure port and program to start
EXPOSE 80
COPY start.sh start.sh
CMD ["sh", "start.sh"]
