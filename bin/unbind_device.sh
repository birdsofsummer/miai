#!/bin/sh
LOG_TITLE=$0
mico_log() {
    logger -t $LOG_TITLE[$$] -p 3 "$*"
}

restart_bind_service() {
    ubus call voip cmcc_unregister
    sleep 1
    /usr/bin/mphelper pause
    mico_log "unregister device & reboot"
    rm -r -f /data/* > /dev/null 2>&1
    rm -r -f /data/.* >/dev/null 2>&1
    sync
    /usr/bin/mphelper tone /usr/share/sound/shutdown.mp3
    reboot
}

case $1 in
*)
restart_bind_service
;;
esac
