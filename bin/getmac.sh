#!/bin/sh

case "$1" in
    sn)
        uci -c /data/etc get binfo.binfo.sn
        ;;
    did)
        uci -c /data/etc get binfo.binfo.miio_did
        uci -c /data/etc get binfo.binfo.miio_key
        ;;
    miio_did)
        uci -c /data/etc get binfo.binfo.miio_did
        ;;
    miio_key)
        uci -c /data/etc get binfo.binfo.miio_key
        ;;
    mac)
        uci -c /data/etc get binfo.binfo.mac_wifi
        ;;
    mac_bt)
        uci -c /data/etc get binfo.binfo.mac_bt
        ;;

    *)
        uci -c /data/etc get binfo.binfo.mac_wifi
        ;;
esac
