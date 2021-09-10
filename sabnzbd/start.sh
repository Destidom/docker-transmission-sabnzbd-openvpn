#!/bin/bash

# Source our persisted env variables from container startup
. /etc/sabnzbd/environment-variables.sh

# This script will be called with tun/tap device name as parameter 1, and local IP as parameter 4
# See https://openvpn.net/index.php/open-source/documentation/manuals/65-openvpn-20x-manpage.html (--up cmd)
echo "Up script executed with $*"
if [[ "$4" = "" ]]; then
  echo "ERROR, unable to obtain tunnel address"
  echo "killing $PPID"
  kill -9 $PPID
  exit 1
fi

# If sabnzbd-pre-start.sh exists, run it
if [[ -x /scripts/sabnzbd-pre-start.sh ]]; then
  echo "Executing /scripts/sabnzbd-pre-start.sh"
  /scripts/sabnzbd-pre-start.sh "$@"
  echo "/scripts/sabnzbd-pre-start.sh returned $?"
fi

echo "Updating SABNZBD_BIND_ADDRESS_IPV4 to the ip of $1 : $4"
export SABNZBD_BIND_ADDRESS_IPV4=$4
# Also update the persisted settings in case it is already set. First remove any old value, then add new.
sed -i '/SABNZBD_BIND_ADDRESS_IPV4/d' /etc/sabnzbd/environment-variables.sh
echo "export SABNZBD_BIND_ADDRESS_IPV4=$4" >>/etc/sabnzbd/environment-variables.sh

echo "Updating Sabnzbd sabnzbd.ini with values from env variables"
# Ensure SABNZBD_HOME is created
mkdir -p ${SABNZBD_HOME}
python3 /etc/sabnzbd/updateSettings.py /etc/sabnzbd/default-sabnzbd.ini ${SABNZBD_HOME}/sabnzbd.ini || exit 1

echo "sed'ing True to true"
sed -i 's/True/true/g' ${SABNZBD_HOME}/sabnzbd.ini

if [[ ! -e "/dev/random" ]]; then
  # Avoid "Fatal: no entropy gathering module detected" error
  echo "INFO: /dev/random not found - symlink to /dev/urandom"
  ln -s /dev/urandom /dev/random
fi

. /etc/sabnzbd/userSetup.sh

if [[ "true" = "$DROP_DEFAULT_ROUTE" ]]; then
    echo "DROPPING DEFAULT ROUTE"
    # Remove the original default route to avoid leaks.
    /sbin/ip route del default via "${route_net_gateway}" || exit 1
fi

if [[ "true" = "$LOG_TO_STDOUT" ]]; then
  LOGFILE=/dev/stdout
else
  LOGFILE=${SABNZBD_HOME}/sabnzbd.log
fi

echo "STARTING SABNZBD"
exec su --preserve-environment ${RUN_AS} -s /bin/bash -c "/usr/bin/sabnzbdplus  -f ${SABNZBD_HOME}/sabnzbd.ini --logfile $LOGFILE" &

# Configure port forwarding if applicable
if [[ -x /etc/openvpn/${OPENVPN_PROVIDER,,}/update-port.sh && -z $DISABLE_PORT_UPDATER ]]; then
  echo "Provider ${OPENVPN_PROVIDER^^} has a script for automatic port forwarding. Will run it now."
  echo "If you want to disable this, set environment variable DISABLE_PORT_UPDATER=true"
  exec /etc/openvpn/${OPENVPN_PROVIDER,,}/update-port.sh &
fi

# If sabnzbd-post-start.sh exists, run it
if [[ -x /scripts/sabnzbd-post-start.sh ]]; then
  echo "Executing /scripts/sabnzbd-post-start.sh"
  /scripts/sabnzbd-post-start.sh "$@"
  echo "/scripts/sabnzbd-post-start.sh returned $?"
fi

echo "Sabnzbd startup script complete."
