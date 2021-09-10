#!/bin/bash

/etc/transmission/stop.sh
/etc/sabnzbd/stop.sh
[[ -f /opt/privoxy/stop.sh ]] && /opt/privoxy/stop.sh
