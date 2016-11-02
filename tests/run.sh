#!/bin/sh

set -e
set -x

SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

. $SCRIPTPATH/immut.shell-lib


if [ "x$TMPDIR" == "x" ]; then
    TMPDIR="/tmp"
fi

TMPDIR="$TMPDIR/testSuite"
mkdir -p "$TMPDIR"
TMPDIR=$(mktemp -d -p "$TMPDIR")
export TMPDIR



docker_create_container() {
    type="$1"
    docker run -d --cidfile "$TMPDIR/$type.cid" "$type"
}

docker_kill_container() {
    type="$1"
    docker kill `cat "$TMPDIR/$type.cid"` || true
    docker rm `cat "$TMPDIR/$type.cid"` || true
    rm "$TMPDIR/$type.cid" || true
}


run_in_docker(){
    cid_file="$1"
    shift
    docker exec `cat "$cid_file"` sh -c "$@"
}

docker_set_user(){
    type="$1"
    user="$2"
    pass="$3"
    
    #IMPLEMENTS GIVEN  user (\S+) with password (\S+) exist
    # Authenticate using local accounts
    run_in_docker "$TMPDIR/$type.cid" "sed -e 's/sss/unix/g' -i /etc/pam.d/sss_git"
    # Make /etc/shadow readable for all users
    run_in_docker "$TMPDIR/$type.cid" "chmod 644 /etc/shadow"
    # Create new user and password
    run_in_docker "$TMPDIR/$type.cid" "useradd -M $user"
    run_in_docker "$TMPDIR/$type.cid" "echo $user:$pass | chpasswd"
}

docker_get_ip(){
    type="$1"
    cid=$(cat "$TMPDIR/$type.cid")
    ip="$(docker inspect  --format '{{ .NetworkSettings.IPAddress }}' $cid)"
    echo $ip
}


## FIXME
## Duplicated from packer/files/boot-config/config.sh


# Create empty haproxy configuration file
HAPROXYDIR="$TMPDIR/immut-haproxy"
HAPROXYCONF="$HAPROXYDIR/haproxy.cfg"
mkdir -p "$HAPROXYDIR"
cp "$SCRIPTPATH"/haproxy.cfg "$HAPROXYCONF"

projects="test"
services="gitserver"
for i in $projects; do
    for j in $services; do
        # Update haproxy configuration
        echo "    acl host_""$i""_""$j"" hdr(host) -m beg -i ""$j"".""$i" >> "$HAPROXYCONF"
        echo "    use_backend ""$i""_""$j""_""http if host_""$i""_""$j" >> "$HAPROXYCONF"
        echo >> "$HAPROXYCONF"
    done
done


for i in $projects; do
    for j in $services; do
        # Launch container
        
        docker_create_container $j
        ip="$(docker_get_ip $j)"
        docker_set_user $j testuser testpass

        # Update haproxy with IP
        echo "backend ""$i""_""$j""_http" >> "$HAPROXYCONF"
        echo "    server ""$i""_""$j"" ""$ip"":80" >> "$HAPROXYCONF"
        echo >> "$HAPROXYCONF"
    done
done

docker run -d -v=$HAPROXYDIR:/data/:rw \
           --cidfile "$TMPDIR/haproxy.cid" \
           haproxy




read

## Cleanup
for i in $projects; do
    for j in $services; do
        # Launch container
        docker_kill_container $j
    done
done
docker_kill_container haproxy

exit 1



if command -v yarn > /dev/null; then
    yarn --tempdir "$TMPDIR" \
         -s immut.shell-lib yarns/*.yarn
else
    echo "WARNING: 'yarn' scenario test tool (part of 'cmdtest' " \
         "package) was not found." >&2
    exit 1
fi


