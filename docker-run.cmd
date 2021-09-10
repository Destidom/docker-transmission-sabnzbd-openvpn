sudo docker run --cap-add=NET_ADMIN -d --restart always -d \
              -v /mnt/hdd5/downloads/:/data \
              -v /home/pi/openvpn/Trust.Zone-Netherlands-Haarlem.ovpn:/etc/openvpn/custom/default.ovpn \
              -e OPENVPN_PROVIDER=CUSTOM \
              -e OPENVPN_USERNAME=DWXiW \
              -e OPENVPN_PASSWORD=UEBEiSfj \
              -e LOCAL_NETWORK=192.168.192.0/24 \
              -e TZ=NL \
              -e ENABLE_UFW=true \
              --log-driver json-file \
              --log-opt max-size=10m \
              -p 9091:9091 \
              -p 8080:8080 \
	      --dns 1.1.1.1 \
              --dns 1.0.0.1 \
              hvos234/docker-transmission-sabnzbdplus-openvpn:4.0-hvos234