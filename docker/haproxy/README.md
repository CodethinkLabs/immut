# Simple HAProxy Fedora container

To create the SSL certificate file

    $ openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 9999
    $ cat cert.pem key.pem > ssl.pem

To edit haproxy configuration edit `haproxy.cfg`

To build the container

    $ docker build -t haproxy .

Run the container

    $ docker run -i -t -p 80:80 -p 443:443 -v=/dev/log:/dev/log haproxy
