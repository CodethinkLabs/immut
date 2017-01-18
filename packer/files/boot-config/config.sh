#!/bin/sh

set -e


SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

projects=$1
services=$2
usergroups=$3

# Stop and remove docker instances and networks
docker kill $(docker ps -a -q) || true
docker rm $(docker ps -a -q) || true
docker network rm $(docker network ls -q) || true

# Remove any autofs configuration
rm /etc/auto.master.d/* || true
rm /etc/auto.master || true

# Create main subnetwork
docker network create --subnet=172.101.0.0/16 immut-net

# Create empty haproxy configuration file
HAPROXYDIR="/var/lib/immut-haproxy"
HAPROXYCONF="$HAPROXYDIR/haproxy.cfg"
mkdir -p "$HAPROXYDIR"
cp "$SCRIPTPATH"/haproxy.cfg "$HAPROXYCONF"

for project in $projects; do
    mkdir -p /var/data/"$project"/public_html
    echo "public_html" -rw,soft :/var/data/"$project"/public_html >> /etc/auto.master.d/auto."$project"
    for service in $services; do
        # Create autofs configuration file
        mkdir -p /var/data/"$project"/"$service"
        echo "$service" -rw,soft :/var/data/"$project"/"$service" >> /etc/auto.master.d/auto."$project"
        echo /var/lib/immut/"$project" /etc/auto.master.d/auto."$project" >> /etc/auto.master

        # Update haproxy configuration
        echo "    acl host_""$project""_""$service"" hdr(host) -m beg -i ""$service"".""$project" >> "$HAPROXYCONF"
        echo "    use_backend ""$project""_""$service""_""http if host_""$project""_""$service" >> "$HAPROXYCONF"
        echo >> "$HAPROXYCONF"
    done
done

# Start autofs once it's configured, and before starting the containers
systemctl start autofs

ip=3

for project in $projects; do
    echo $project project
    # Create user/group/home-folder for project
    adduser $project || true

    for usergroup in $usergroups; do
        echo $usergroup usergroup
        # Create user group
        groupadd "$project"_"$usergroup" || true
    done

    for service in $services; do
        echo $service service
        echo "$project"_"$service" project service
        # Launch container
        docker run -d -v=/dev/log:/dev/log --net immut-net \
                   --ip 172.101.0.$ip \
                   -e "PROJECT_NAME=$project" \
                   -v=/var/lib/immut/$project/$service:/data/$service:rw \
                   -v=/var/lib/immut/$project/public_html:/data/public_html:rw \
                   -v=/var/lib/sss/pipes/:/var/lib/sss/pipes/:rw \
                   -v=/run/dbus/system_bus_socket:/run/dbus/system_bus_socket:rw \
                   $service # Service name has to match docker image name

        # Update haproxy with IP
        echo "backend ""$project""_""$service""_http" >> "$HAPROXYCONF"
        echo "    server ""$project""_""$service"" 172.101.0.""$ip"":80" >> "$HAPROXYCONF"
        echo >> "$HAPROXYCONF"

        ip=$(expr $ip + 1)
    done
done

docker run -d -p 80:80 -p 443:443 -v=/dev/log:/dev/log \
           --net immut-net --ip 172.101.0.2 \
           -v=/var/lib/sss/pipes/:/var/lib/sss/pipes/:rw \
           -v=$HAPROXYDIR:/data/:rw \
           haproxy
