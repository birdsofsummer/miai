#!/bin/sh
#####################CTEI
#LOG_TITLE="carrier.sh"
#mico_log() {
#    logger -t $LOG_TITLE[$$] -p 3 "$*"
#    echo $*
#}

. /usr/share/libubox/jshn.sh

LOG_TITLE="carrier.sh"
mico_log() {
    logger -t $LOG_TITLE[$$] -p 3 "$*"
    echo $*
}

china_telecom()
{
    local tmp_outfile="/tmp/china_telecom.output"
    CTEI=$(cat /data/messagingagent/CTEI)
    [ -z $CTEI ] && {
        mico_log "CTEI empty, no report"
        return;
    }
    local wan_ip=$(ifconfig wlan0 | grep "inet addr" | awk '{ print $2}'|awk -F':' '{print $2}')
    local wan_mac=$(matool_get_mac)
    local rom_version=$(matool_get_rom_version)
    mico_log "CTEI $CTEI"
    mico_log "ip  $wan_ip"
    mico_log "mac $wan_mac"
    mico_log "version $rom_version"
    
    for try_times in `seq 1 3`;
    do
        local update_date=$(date +%F" "%X)
        mico_log "date $update_date"
        post_content="{\"VER\":\"01\",\"CTEI\":\"${CTEI}\",\"MAC\":\"24:e2:71:f4:d7:b0\",\"IP\":\"${wan_ip}\",\"UPLINKMAC\":\"\",\"LINK\":\"2\",\"FWVER\":\"${rom_version}\",\"DATE\":\"${update_date}\"}"
        mico_log "try $try_times times pdm send:$post_content"
        #curl -v  -X POST --data "{\"VER\":\"01\",\"CTEI\":\"${CTEI}\",\"MAC\":\"24:e2:71:f4:d7:b0\",\"IP\":\"${wan_ip}\",\"UPLINKMAC\":\"\",\"LINK\":\"2\",\"FWVER\":\"${rom_version}\",\"DATE\":\"${update_date}\"}" http://pdm.tydevice.com
        #curl -v http://pdm.tydevice.com/?jsonstr=$post_content
        wget -O $tmp_outfile "http://pdm.tydevice.com/?jsonstr=$post_content"
        json_init
        json_load "$(cat $tmp_outfile)"
        json_get_var status_code "Status Code"
        json_get_var errmsg "errmsg"
        json_cleanup

        mico_log "$(cat $tmp_outfile)"
        mico_log "status_code $status_code"
        mico_log "errmsg $errmsg"
        [ "$status_code" == "200" ] && {
            mico_log "report success ,exit"
            break
        }
        sleep 10
    done
}

while true
do
    china_telecom
    #sleep 86400
    sleep 86400
done
