FROM gitserver_base

WORKDIR /git-server/

# Configure SSSD PAM client
COPY sss_git /etc/pam.d/sss_git

# Create Apache server for Git and CGit
COPY git-server.conf /etc/httpd/conf.d/git-server.conf

# Configure port and program to start
EXPOSE 80
COPY start.sh start.sh
CMD ["sh", "start.sh"]
