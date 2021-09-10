#! /bin/bash

# If sabnzbd-pre-stop.sh exists, run it
if [[ -x /scripts/sabnzbd-pre-stop.sh ]]
then
    echo "Executing /scripts/sabnzbd-pre-stop.sh"
    /scripts/sabnzbd-pre-stop.sh "$@"
    echo "/scripts/sabnzbd-pre-stop.sh returned $?"
fi

echo "Sending kill signal to sabnzbdplus"
PID=$(pidof sabnzbdplus)
kill "$PID"

# Give sabnzbdplus some time to shut down
SABNZBD_TIMEOUT_SEC=${SABNZBD_TIMEOUT_SEC:-5}
for i in $(seq "$SABNZBD_TIMEOUT_SEC")
do
    sleep 1
    [[ -z "$(pidof sabnzbdplus)" ]] && break
    [[ $i == 1 ]] && echo "Waiting ${SABNZBD_TIMEOUT_SEC}s for sabnzbdplus to die"
done

# Check whether sabnzbdplus is still running
if [[ -z "$(pidof sabnzbdplus)" ]]
then
    echo "Successfuly closed sabnzbdplus"
else
    echo "Sending kill signal (SIGKILL) to sabnzbdplus"
    kill -9 "$PID"
fi

# If sabnzbd-post-stop.sh exists, run it
if [[ -x /scripts/sabnzbd-post-stop.sh ]]
then
    echo "Executing /scripts/sabnzbd-post-stop.sh"
    /scripts/sabnzbd-post-stop.sh "$@"
    echo "/scripts/sabnzbd-post-stop.sh returned $?"
fi
