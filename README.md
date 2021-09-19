# OpenVPN, Transmission and Sabnzbdplus with WebUI

This container contains OpenVPN, Transmission and Sabnzbdplus with a configuration
where Transmission and Sabznbdplus is running only when OpenVPN has an active tunnel.
It has built in support for many popular VPN providers to make the setup easier.

## This is a fork of 
This is a fork of https://github.com/haugene/docker-transmission-openvpn
I used the 4.0 release and bulid a new one 4.0-hvos234.
I only added sabnzbdplus and extra ufw rules (when enabled). See the 'sabnzbd' folder. I changed the main dockerfile file, 
the /openvpn/start.sh, /openvpn/tunnelDown.sh, /openvpn/tunnelUp.sh etc.
I did not test if the privoxy works or the rss.

Beside sabnzdbplus i added some firewall rules (when ENABLE_UFW=true), to make sure even when the openvpn is not started and the transmission
daemon or sanbnzbd is, that the firewall rules block everything.
  ufw default deny incoming
  ufw default deny outgoing
  ufw allow out on tun0
  ufw allow out on eth0 to any port 53,${OPENVPN_PORT=} proto ${OPENVPN_PROTO}
  ufw allow out on wlan0 to any port 53,${OPENVPN_PORT=} proto ${OPENVPN_PROTO}

## Run with
sudo docker run --cap-add=NET_ADMIN -d --restart always -d \
              -v /mnt/hdd5/downloads/:/data \
              -v /home/pi/openvpn/OPENVPNFILE.ovpn:/etc/openvpn/custom/default.ovpn \
              -e OPENVPN_PROVIDER=CUSTOM \
              -e OPENVPN_USERNAME=USERNAME \
              -e OPENVPN_PASSWORD=PASSWORD \
              -e OPENVPN_PROTO=udp \
              -e OPENVPN_PORT=1194 \
              -e LOCAL_NETWORK=192.168.192.0/24 \
              -e TZ=NL \
              -e ENABLE_UFW=true \
              -e TRANSMISSION_RPC_USERNAME=transmission \
              -e TRANSMISSION_RPC_PASSWORD=PASSWORD \
              -e GLOBAL_APPLY_PERMISSIONS=false \
              --log-driver json-file \
              --log-opt max-size=10m \
              -p 9091:9091 \
              -p 8080:8080 \
	      --dns 1.1.1.1 \
              --dns 1.0.0.1 \
              hvos234/docker-transmission-sabnzbdplus-openvpn:4.0-hvos234

Do not forget to change the OPENVPNFILE, USERNAME, PASSWORD, PASSWORD and also the 192.168.192.0/24 to your situation.
Run the container once and ajust the ${TRANSMISSION_HOME}/settings.json and the ${SABNZBD_HOME}/sabnzbd.ini to your liking!
Do not forget to change the "APi-key" and the "NZB-key" in sabznbd!

When you run this , it will copy the 'default-settings.json' file to the ${TRANSMISSION_HOME}/settings.json (if not exists) 
and the 'default-sabnzbd.ini' files to ${SABNZBD_HOME}/sabnzbd.ini (if not exists), and replaces all the 
envoirment variabels started with 'TRANSMISSION_' (for the settings.json) and 'SABNZBD_' (for the sabnzbd.ini) in the settings.json
and of course the sabnzbd.ini file. You can start the a container the first time and make alterations in both files 
without any of the envoirment variables.

## Documentation
You can find the original documentation on https://haugene.github.io/docker-transmission-openvpn/

# Original documenation!
## Read this first 

The documentation for this image is hosed on GitHub pages:

https://haugene.github.io/docker-transmission-openvpn/

If you can't find what you're looking for there, please have a look
in the [discussions](https://github.com/haugene/docker-transmission-openvpn/discussions)
as we're trying to that for general questions.

If you have found what you believe to be an issue or bug, create an issue and provide
enough details for us to have a chance to reproduce it or undertand what's going on.
**NB:** Be sure to search for similar issues (open and closed) before opening a new one.

### Just started having problems?

We've just merged a larger release from dev to the master branch.
This means that the `latest` tag of this image now is version 4.0.

If this release causes issues for you, try running the latest 3.x release:
`haugene/transmission-openvpn:3.7.1`. Note that this is a temporary fix,
there will not be any more releases on the 3.x line.

Any instabilities with 4.0, please take it up in the 4.0 release discussion:
[https://github.com/haugene/docker-transmission-openvpn/discussions/1936](https://github.com/haugene/docker-transmission-openvpn/discussions/1936)

## Quick Start

These examples shows valid setups using PIA as provider for both
docker run and docker-compose. Note that you should read some documentation
at some point, but this is a good place to start.

### Docker run

```
$ docker run --cap-add=NET_ADMIN -d \
              -v /your/storage/path/:/data \
              -e OPENVPN_PROVIDER=PIA \
              -e OPENVPN_CONFIG=france \
              -e OPENVPN_USERNAME=user \
              -e OPENVPN_PASSWORD=pass \
              -e LOCAL_NETWORK=192.168.0.0/16 \
              --log-driver json-file \
              --log-opt max-size=10m \
              -p 9091:9091 \
              haugene/transmission-openvpn
```

### Docker Compose
```
version: '3.3'
services:
    transmission-openvpn:
        cap_add:
            - NET_ADMIN
        volumes:
            - '/your/storage/path/:/data'
        environment:
            - OPENVPN_PROVIDER=PIA
            - OPENVPN_CONFIG=france
            - OPENVPN_USERNAME=user
            - OPENVPN_PASSWORD=pass
            - LOCAL_NETWORK=192.168.0.0/16
        logging:
            driver: json-file
            options:
                max-size: 10m
        ports:
            - '9091:9091'
        image: haugene/transmission-openvpn
```

## Please help out (about:maintenance)
This image was created for my own use, but sharing is caring, so it had to be open source.
It has now gotten quite popular, and that's great! But keeping it up to date, providing support, fixes
and new features takes time. If you feel that you're getting a good tool and want to support it, there are a couple of options:

A small montly amount through [![Donate with Patreon](images/patreon.png)](https://www.patreon.com/haugene) or
a one time donation with [![Donate with PayPal](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=73XHRSK65KQYC)

All donations are greatly appreciated! Another great way to contribute is of course through code.
A big thanks to everyone who has contributed so far!
