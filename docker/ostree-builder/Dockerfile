FROM fedora:24

RUN dnf -y install rpm-ostree git nc zip
RUN mkdir /data

WORKDIR /workdir

COPY start.sh start.sh
COPY fedora-atomic-update-tree.json fedora-atomic-update-tree.json
COPY fedora-atomic-haproxy.json fedora-atomic-haproxy.json
COPY fedora-atomic-gitserver.json fedora-atomic-gitserver.json
COPY fedora-atomic-yarn-runner.json fedora-atomic-yarn-runner.json
COPY treecompose-var-post.sh treecompose-var-post.sh
RUN chmod +x treecompose-var-post.sh
CMD ["sh", "start.sh"]
