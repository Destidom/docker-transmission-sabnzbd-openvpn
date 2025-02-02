#!/bin/bash

# More/less taken from https://github.com/linuxserver/docker-baseimage-alpine/blob/3eb7146a55b7bff547905e0d3f71a26036448ae6/root/etc/cont-init.d/10-adduser

RUN_AS=root

if [ -n "$PUID" ] && [ ! "$(id -u root)" -eq "$PUID" ]; then
    RUN_AS=abc
    if [ ! "$(id -u ${RUN_AS})" -eq "$PUID" ]; then
        usermod -o -u "$PUID" ${RUN_AS};
    fi
    if [ -n "$PGID" ] && [ ! "$(id -g ${RUN_AS})" -eq "$PGID" ]; then
        groupmod -o -g "$PGID" ${RUN_AS};
    fi

    if [[ "true" = "$LOG_TO_STDOUT" ]]; then
      chown ${RUN_AS}:${RUN_AS} /dev/stdout
    fi

    # Make sure directories exist before chown and chmod
    mkdir -p /config \
        "${SABNZBD_HOME}" \
        "${SABNZBD_DIRSCAN_DIR}" \
        "${SABNZBD_DOWNLOAD_DIR}" \
        "${SABNZBD_COMPLETE_DIR}" \
        "${SABNZBD_SCRIPT_DIR}"

    echo "Enforcing ownership on sabnzbd config directories"
    chown -R ${RUN_AS}:${RUN_AS} \
        /config \
        "${SABNZBD_HOME}"

    echo "Applying permissions to sabnzbd config directories"
    chmod -R go=rX,u=rwX \
        /config \
        "${SABNZBD_HOME}"

    if [ "$GLOBAL_APPLY_PERMISSIONS" = true ] ; then
        echo "Setting owner for sabnzbd paths to ${PUID}:${PGID}"
        chown -R ${RUN_AS}:${RUN_AS} \
            "${SABNZBD_DIRSCAN_DIR}" \
            "${SABNZBD_DOWNLOAD_DIR}" \
            "${SABNZBD_COMPLETE_DIR}" \
            "${SABNZBD_SCRIPT_DIR}"

        echo "Setting permissions for download and complete directories"
        SABNZBD_UMASK_OCTAL=$(printf '%03g' $(printf '%o\n' $(jq .umask ${SABNZBD_HOME}/sabnzbd.ini)))
        DIR_PERMS=$(printf '%o\n' $((0777 & ~SABNZBD_UMASK_OCTAL)))
        FILE_PERMS=$(printf '%o\n' $((0666 & ~SABNZBD_UMASK_OCTAL)))
        echo "Mask: ${SABNZBD_UMASK_OCTAL}"
        echo "Directories: ${DIR_PERMS}"
        echo "Files: ${FILE_PERMS}"

        find "${SABNZBD_DOWNLOAD_DIR}" "${SABNZBD_COMPLETE_DIR}" "${SABNZBD_SCRIPT_DIR}" -type d \
        -exec chmod $(printf '%o\n' $((0777 & ~SABNZBD_UMASK_OCTAL))) {} +
        find "${SABNZBD_DOWNLOAD_DIR}" "${SABNZBD_COMPLETE_DIR}" "${SABNZBD_SCRIPT_DIR}" -type  f \
        -exec chmod $(printf '%o\n' $((0666 & ~SABNZBD_UMASK_OCTAL))) {} +

        echo "Setting permission for watch directory (775) and its files (664)"
        chmod -R o=rX,ug=rwX \
            "${SABNZBD_DIRSCAN_DIR}"
    fi
fi

echo "
-------------------------------------
Sabnzbd will run as
-------------------------------------
User name:   ${RUN_AS}
User uid:    $(id -u ${RUN_AS})
User gid:    $(id -g ${RUN_AS})
-------------------------------------
"

export PUID
export PGID
export RUN_AS
