FROM haproxy_base

WORKDIR /haproxy
COPY haproxy.cfg /etc/haproxy/haproxy.cfg
COPY ssl.pem /etc/pki/tls/private/cert.pem

RUN mkdir -p /var/lib/haproxy/

# Configure port and program to start
EXPOSE 80
COPY start.sh start.sh
CMD ["sh", "start.sh"]
