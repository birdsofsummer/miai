#!/bin/sh
# minet_client -s 169.254.29.1 -m "34:CE:00:9D:FE:94" -d "60846786" -k "7oA2M2RasxqwSApe"
. /usr/share/libubox/jshn.sh

WHICH_SSID="minet_ready"
LOG_TITLE="minet_service.sh"
mico_log() {
    logger -t $LOG_TITLE[$$][REGISTER] -p 3 "$*"
    echo $* 
}

ap_mode_timeout() 
{
    [ -f /tmp/ntp.status ] && {
        mico_log "time synced, minet service is no more needed working, exit."
        exit 0;
    };
    
    local current_time=$(date +%s)
    
    [ $current_time -ge $AP_MODE_END_TIME ] && { 
        mico_log "ap mode timeout $current_time end $AP_MODE_END_TIME"
        mico_log "ap mode timeout $AP_MODE_TIMEOUT_INT"
        AP_MODE_STOPED=1
        killall -9 hostapd
        wl down
        mico_log "ap mode reached timeout $AP_MODE_TIMEOUT_INT"
        mico_log "ap mode stop."
        mico_log "minet scan stop."
        mico_log "minet scan and ap mode need restart device to recover."
        exit 0;
    };

    return 0;
}


mico_log "minet start."
#after scan flag, still need 10 seconds to wait for 
# "/bin/notify.sh welcome " complete
sleep 11

AP_MODE_TIMEOUT_INT=1800
AP_MODE_END_TIME=$(($(date +%s) + $AP_MODE_TIMEOUT_INT))
mico_log "ap mode timeout time $(date +%s) -- $AP_MODE_END_TIME"
scan_stop_flag=0

while true
do
    [ -f /data/status/config_done ] && {
        wireless_log "already registed. exit."
        exit 0;
    }

    #this function may exit script.
    ap_mode_timeout

    [ "$scan_stop_flag" != "0" ] && {
        sleep 10
        continue;
    }

    /etc/init.d/wireless scan $WHICH_SSID
    [ $? -ne 1 ] && {
        sleep 10;
        continue;
    }

    /etc/init.d/wireless minet_register $WHICH_SSID
    result=$?
    case $result in
    "0")
        exit;
        ;;
    "1")
       　
        sleep 3
        continue
        ;;
    "2")
        scan_stop_flag=1
        mico_log "no more minet_ready scan."
        ;;
    *)
        sleep 1
    esac
done


