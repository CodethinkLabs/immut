# Developer Guide


## Setting Up A Development Environment

NOTE: This will result in a devel environment that is similar to the system
created from the master branch, but not identical. TODO: update this.

1. Clone the pre-ostree-containers branch of this repo

2. cd into the docker/git-server directory of the repo

3. Build the docker container that can run the gitserver:

    $ docker build -t gitserver-apache .

4. Run the container:

    $sudo docker run -i -t  -p 8000:80 -v=/docker/:/data/:rw gitserver-apache

This will automatically start the start.sh script within the container, and run a git server. You can stop it at any time, change the config in the gitserver directory, and then rebuild the docker container, to see the results of your changes. Alternatively, if you wish to make changes and test as you go along, in the same container, run:

    $sudo docker run -i -t  -p 8000:80 -v=/docker/:/data/:rw gitserver-apache/ /bin/bash

Then, make changes on the system. When you want to run the git server, you should run the start.sh script, located in /git-server within the container.

Using the instructions above, your repos will be located in /docker . If you want to add hooks to those, you should cd to the relevant repo and put hooks in there.


## Testing Changes

TODO

## Sending Patches

Send a pull request against this repo!
