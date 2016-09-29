FROM fedora:24

RUN dnf -y update
RUN dnf -y install httpd
RUN dnf -y install mod_authnz_pam
RUN dnf -y install git-core
RUN dnf -y install cgit

WORKDIR /git-server/
RUN mkdir /data

# Configure SSSD PAM client
RUN dnf -y install sssd-client
COPY sss_git /etc/pam.d/sss_git

RUN dnf -y clean all

# Create Apache server for Git and CGit
COPY git-server.conf /etc/httpd/conf.d/git-server.conf
COPY cgit.conf /etc/httpd/conf.d/cgit.conf


# Configure port and program to start
EXPOSE 80
COPY start.sh start.sh
CMD ["sh", "start.sh"]
