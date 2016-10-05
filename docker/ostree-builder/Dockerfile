FROM fedora:24

RUN dnf -y install rpm-ostree git nc
RUN mkdir /data

WORKDIR /workdir

COPY start.sh start.sh
COPY fedora-atomic-update-tree.json fedora-atomic-update-tree.json
COPY fedora-atomic-haproxy.json fedora-atomic-haproxy.json
COPY fedora-atomic-gitserver.json fedora-atomic-gitserver.json
CMD ["sh", "start.sh"]
