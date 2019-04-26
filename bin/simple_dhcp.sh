#!/bin/sh

MICO_SYSLOG_BINDDEVICE="[MICOREGISTER] "
MICO_SYSLOG_PERFORMANCE="[performance] "

export LED_PARENT=simple_dhcp.sh
LOG_TITLE=$0
mico_log() {
    logger -t $LOG_TITLE[$$] -p 3 "$*"
}
[ -z "$1" ] && echo 'Error: should be called from udhcpc' && exit 1

[ -n "$broadcast" ] && BROADCAST="broadcast $broadcast"
[ -n "$subnet" ] && NETMASK="netmask $subnet"

setup_dns() {
    RESOLV_CONF="/tmp/resolv.conf.auto"
    RESOLV_CONF_TMP="/tmp/resolv.conf.auto.tmp"
    DNS_SERVERS_CN="180.76.76.76 223.5.5.5 223.6.6.6"
    DNS_SERVERS_CN=$(echo $DNS_SERVERS_CN |awk 'BEGIN{srand()}{for(i=1;i<=NF;i++) b[rand()NF]=$i}END{for(x in b)printf "%s ",b[x]}')

    echo -n > $RESOLV_CONF_TMP

    #if ble connect time great than 1 times, use predefined dns list
    local connect_times=0;
    mkdir -p /data/status/
    local CONNECT_TIMES_FILE="/data/status/mico_try_register_times"
    local country=$(uci -c /data/etc get binfo.binfo.country)
    country=${country:-CN}
    local connect_times=$(cat $CONNECT_TIMES_FILE)
    connect_times=${connect_times:-0}

    mico_log "country $country connect times $connect_times"
    [ "$country" == "CN" -a $connect_times -gt 1 ] && {
        dns=$DNS_SERVERS_CN
        domain=""
    }

    [ -n "$domain" ] && {
        mico_log "domain $domain"
        echo search $domain >> $RESOLV_CONF_TMP
    }

    mico_log "dns list $dns"
    for i in $dns ; do
        echo nameserver $i >> $RESOLV_CONF_TMP
    done

    cp $RESOLV_CONF_TMP $RESOLV_CONF -f >> /dev/null
}

setup_interface () {
    /sbin/ifconfig $interface $ip $BROADCAST $NETMASK

    if [ -n "$router" ] ; then
        while route del default gw 0.0.0.0 dev $interface ; do
            true
        done
    
        for i in $router ; do
            route add default gw $i dev $interface
        done
    fi
    setup_dns
}

deconfig_interface() {
    /sbin/ifconfig $interface 0.0.0.0
}

case "$1" in
    deconfig)
        mico_log "[deconfig dhcp] release ip"
        [ ! -f /tmp/ap_config_mode_flag ] && {
            [ ! -f /tmp/wifi_check_ccmp_err ] && {
                mico_log "[dhcp led] show led 6"
                /bin/show_led 6
            }
        }
        deconfig_interface

    ;;
    renew)
        setup_interface
        mico_log "[renew dhcp]"
    ;;
    bound)
        setup_interface
        mico_log "[dhcp get ip success.]"
        /etc/init.d/dnsmasq  restart 1>/dev/null 2>&1
        mkdir -p /data/status/
                
        [ -f /data/status/dhcp_done ] && logger stat_points_none spk_wifi_reconnect=1
        [ ! -f /data/status/dhcp_done ] && logger stat_points_none spk_wifi_connect=1
        echo "$interface $ip $router" > /data/status/dhcp_done
        #killall -9 ntpsetclock
        #/bin/ntpsetclock loop &
        mico_log "[dhcp restart services, services:[dlna,mitv-disc,alarm]]"
        /etc/init.d/dlnainit restart 1>/dev/null 2>&1
        /etc/init.d/mitv-disc  restart 1>/dev/null 2>&1
        /etc/init.d/alarm restart 1>/dev/null 2>&1
        [ ! -f /tmp/ap_config_mode_flag ] && {
            /etc/init.d/miio restart
        }
        mico_log "[dhcp restart service success ]"
#       /etc/init.d/messagingagent restart 1>/dev/null 2>&1
        if [ ! -f /tmp/wifi_check_ccmp_err ]; then {
            mico_log "[dhcp led] shut led 6"
            /bin/shut_led 6
        }
        else {
            mico_log "[dhcp led] remove wifi_check_ccmp_err"
            rm -f /tmp/wifi_check_ccmp_err
        }
        fi
    ;;
esac
