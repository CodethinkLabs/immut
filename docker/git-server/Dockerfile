FROM gitserver_base

WORKDIR /git-server/

# Configure SSSD PAM client
COPY sss_git /etc/pam.d/sss_git

# Create Apache server for Git and CGit
COPY git-server.conf /etc/httpd/conf.d/git-server.conf

# Include post-receive hook
COPY hooks/post-receive post-receive


# Make pwauth pam conf use sss
RUN ln -sf /etc/pam.d/sss_git /etc/pam.d/pwauth
# Make pwauth runnable by everyone - TODO, only apache user?
RUN chmod 755 /usr/bin/pwauth

# Configure port and program to start
EXPOSE 80
COPY start.sh start.sh
CMD ["sh", "start.sh"]

COPY mod_authz_unixgroup.so  /usr/lib64/httpd/modules/mod_authz_unixgroup.so
