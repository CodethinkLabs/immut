#!/bin/sh

set -e


SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

projects=$1
services=$2

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

for i in $projects; do
    mkdir -p /var/data/"$i"/public_html
    echo "public_html" -rw,soft :/var/data/"$i"/public_html >> /etc/auto.master.d/auto."$i"
    for j in $services; do
        # Create autofs configuration file
        mkdir -p /var/data/"$i"/"$j"
        echo "$j" -rw,soft :/var/data/"$i"/"$j" >> /etc/auto.master.d/auto."$i"
        echo /var/lib/immut/"$i" /etc/auto.master.d/auto."$i" >> /etc/auto.master

        # Update haproxy configuration
        echo "    acl host_""$i""_""$j"" hdr(host) -m beg -i ""$j"".""$i" >> "$HAPROXYCONF"
        echo "    use_backend ""$i""_""$j""_""http if host_""$i""_""$j" >> "$HAPROXYCONF"
        echo >> "$HAPROXYCONF"
    done
done

# Start autofs once it's configured, and before starting the containers
systemctl start autofs

ip=3
for i in $projects; do
    echo $i i
    for j in $services; do
        echo $j j
        echo "$i"_"$j" i j
        # Launch container
        docker run -d -v=/dev/log:/dev/log --net immut-net \
                   --ip 172.101.0.$ip \
                   -v=/var/lib/immut/$i/$j:/data/$j:rw \
                   -v=/var/lib/immut/$i/public_html:/data/public_html:rw \
                   -v=/var/lib/sss/pipes/:/var/lib/sss/pipes/:rw \
                   -v=/run/dbus/system_bus_socket:/run/dbus/system_bus_socket:rw \
                   $j # Service name has to match docker image name

        # Update haproxy with IP
        echo "backend ""$i""_""$j""_http" >> "$HAPROXYCONF"
        echo "    server ""$i""_""$j"" 172.101.0.""$ip"":80" >> "$HAPROXYCONF"
        echo >> "$HAPROXYCONF"

        ip=$(expr $ip + 1)
    done
done

docker run -d -p 80:80 -p 443:443 -v=/dev/log:/dev/log \
           --net immut-net --ip 172.101.0.2 \
           -v=/var/lib/sss/pipes/:/var/lib/sss/pipes/:rw \
           -v=$HAPROXYDIR:/data/:rw \
           haproxy
