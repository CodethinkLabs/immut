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

### Build Image

How to make the image:

    $ docker build -t gitserver .
