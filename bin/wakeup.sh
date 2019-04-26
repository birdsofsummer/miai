#! /bin/sh
export LED_PARENT=wakeup.sh

is_wifi_ready()
{
    STRING=`wpa_cli status 2>/dev/null` || exit 0
    echo $STRING | grep -q 'wpa_state=COMPLETED' || exit 0
}

play_wakeup()
{
    local sec=$(date +%s)
    local wakeup_wav0="/usr/share/sound/wakeup_ei.wav"
    local wakeup_wav1="/usr/share/sound/wakeup_zai.wav"
    local wakeup_wav2="/usr/share/sound/wakeup_wozai.wav"
    local wakeup_wav="wakeup_wav"$(($sec%3))
    local MVOL="255" # max wakeup notify volume 255
    local MINVOL="0" # min wakeup notify volume 0

    # 1. get system volume
    local vol=`ubus -t1 -S call mediaplayer get_media_volume | cut -d':' -f2 |cut -d '}' -f1`
    # 2. turn down volume, player remember current vol.
    ubus -t 1 call mediaplayer player_wakeup {\"action\":\"start\"}
    /usr/bin/mico_voip_service_helper -e wakeup_start & > /dev/null 2>&1

    if [ "$vol" -gt "$MVOL" ]; then
		# 3. tune vol if it is too loud.
        amixer sset notifyvol "$MVOL" > /dev/null
    elif [ "$vol" -gt "$MINVOL" ]; then
        amixer sset notifyvol "$vol" > /dev/null
    fi
    eval wakeup_wav=\$$wakeup_wav
    ubus -t 1 call qplayer play {\"play\":\"$wakeup_wav\"}
    #aplay -D notify $wakeup_wav &> /dev/null
    ubus -t 1 call ai_crontab remove_all &> /dev/null 2>&1
    killall pns_upload_helper &> /dev/null 2>&1
}

play_wakeup_first()
{
    local wakeup_first="/usr/share/sound/first_voice.wav"
    local MVOL="255" # max wakeup notify volume, step 20
    local MINVOL="0" # min wakeup notify volume 0
    local vol=`amixer sget mysoftvol | grep 'Front Left:' | cut -d' ' -f5`

    ubus -t 1 call mediaplayer player_wakeup {\"action\":\"start\"}
    /usr/bin/mico_voip_service_helper -e wakeup_start & > /dev/null 2>&1
    if [ "$vol" -gt "$MVOL" ]; then
		# 3. tune vol if it is too loud.
        amixer sset notifyvol "$MVOL" > /dev/null
    elif [ "$vol" -gt "$MINVOL" ]; then
        amixer sset notifyvol "$vol" > /dev/null
    fi
    # need block, don't use "&" here
    aplay -D notify $wakeup_first > /dev/null
    killall pns_upload_helper &> /dev/null 2>&1
}

play_wakeup_oneshot()
{
    ubus -t 1 call mediaplayer player_wakeup {\"action\":\"start\"}
    /usr/bin/mico_voip_service_helper -e wakeup_start & > /dev/null 2>&1
    killall pns_upload_helper &> /dev/null 2>&1
}

WuW_audio_upload()
{
    local vendor=$(/usr/bin/mico_vendor_helper vendor_name_get)
    #local time=$(TZ=cst-8 date +%y%m%d%H%M%S)
    local time=$(date -u +%y%m%d%H%M%S)
    #local channel=$(matool_get_rom_channel)

    killall pns_upload_helper > /dev/null 2>&1

    #if [ "release" = $channel ] && [ "misWuW" != $2 ]; then
    #    return 0
    #fi

    if [ -d /tmp/mipns/upload/ ]; then
        rm -rf /tmp/mipns/upload/* > /dev/null 2>&1
    else
        mkdir /tmp/mipns/upload/ > /dev/null 2>&1
    fi

    if [ "nuance" = $vendor ]; then
        cp -r /tmp/mipns/nuance/wuw_dump/* /tmp/mipns/upload/ > /dev/null 2>&1
        /usr/bin/pns_upload_helper nuance $2 & > /dev/null 2>&1
        /usr/bin/pns_upload_helper nuance ASR & > /dev/null 2>&1
    elif [ "soundai" = $vendor ]; then
        cp /tmp/mipns/soundai/wuw_dump/* /tmp/mipns/upload/ > /dev/null 2>&1
        rm /tmp/mipns/soundai/wuw_dump/* > /dev/null 2>&1
        cp /tmp/mipns/xiaomi/wuw_dump/* /tmp/mipns/upload/ > /dev/null 2>&1
        rm /tmp/mipns/xiaomi/wuw_dump/* > /dev/null 2>&1
        #if [ "misWuW" = $1 ]; then
        #    /usr/bin/pns_upload_helper soundai $1 $time $2 & > /dev/null 2>&1
        #fi
        # soundai mono-channel
        /usr/bin/pns_upload_helper soundai $1 $time $2 & > /dev/null 2>&1
        # xiaomi original
        /usr/bin/pns_upload_helper xiaomi Original $time $2 & > /dev/null 2>&1
    elif [ "xiaomi" = $vendor ]; then
        cp /tmp/mipns/xiaomi/wuw_dump/* /tmp/mipns/upload/ > /dev/null 2>&1
        rm /tmp/mipns/xiaomi/wuw_dump/* > /dev/null 2>&1
        # xiaomi mono-channel
        /usr/bin/pns_upload_helper xiaomi $1 $time $2 & > /dev/null 2>&1
        # xiaomi original
        /usr/bin/pns_upload_helper xiaomi Original $time $2 & > /dev/null 2>&1
    fi
}

case "$1" in
    WuW)
	play_wakeup
    ;;
    WuW_oneshot)
	play_wakeup_oneshot
    ;;
    WuW_first)
	play_wakeup_first
    ;;
    WuW_uploading)
	WuW_audio_upload $2
    ;;
    bf)
	# angle
	nice -n-20 /bin/show_led 1 "$2"
	;;
    ready)
	nice -n-20 /bin/show_led 11 "$2"
	nice -n-20 /bin/shut_led 2
	ubus -t 1 call mediaplayer player_wakeup {\"action\":\"stop\"}
	/usr/bin/mico_voip_service_helper -e wakeup_end & > /dev/null 2>&1
	WuW_audio_upload $3 $4
	;;
    noangle)
	nice -n-20 /bin/show_led 9
	;;
    stop)
	is_wifi_ready
	nice -n-20 /bin/shut_led 9
	ubus -t 1 call mediaplayer player_wakeup {\"action\":\"stop\"}
	;;
    think)
	nice -n-20 /bin/show_led 2
	;;
    speek)
	nice -n-20 /bin/show_led 3
	;;
    command_timeout)
        ubus -t 1 call mediaplayer player_play_url {\"url\":\"file:///usr/share/sound/command_timeout.mp3\",\"type\":1}
        ;;
    wifi_disconnect)
        ubus -t 1 call mediaplayer player_play_url {\"url\":\"file:///usr/share/sound/wifi_disconnect.mp3\",\"type\":1}
        ;;
    internet_disconnect)
        ubus -t 1 call mediaplayer player_play_url {\"url\":\"file:///usr/share/sound/internet_disconnect.mp3\",\"type\":1}
        ;;
    mibrain_connect_timeout)
        ubus -t 1 call mediaplayer player_play_url {\"url\":\"file:///usr/share/sound/mibrain_connect_timeout.mp3\",\"type\":1}
        ;;
    mibrain_service_timeout)
        ubus -t 1 call mediaplayer player_play_url {\"url\":\"file:///usr/share/sound/mibrain_service_timeout.mp3\",\"type\":1}
        ;;
    mibrain_network_unreachable)
        ubus -t 1 call mediaplayer player_play_url {\"url\":\"file:///usr/share/sound/mibrain_network_unreachable.mp3\",\"type\":1}
        ;;
    mibrain_service_unreachable)
        ubus -t 1 call mediaplayer player_play_url {\"url\":\"file:///usr/share/sound/mibrain_service_unreachable.mp3\",\"type\":1}
        ;;
    mibrain_auth_failed)
        ubus -t 1 call mediaplayer player_play_url {\"url\":\"file:///usr/share/sound/mibrain_auth_failed.mp3\",\"type\":1}
        ;;
    mibrain_start_failed)
        ubus -t 1 call mediaplayer player_play_url {\"url\":\"file:///usr/share/sound/mibrain_start_failed.mp3\",\"type\":1}
        ;;
    upgrade_now)
        ubus -t 1 call mediaplayer player_play_url {\"url\":\"file:///usr/share/sound/upgrade_now.mp3\",\"type\":1}
        ;;
    upgrade_later)
        ubus -t 1 call mediaplayer player_play_url {\"url\":\"file:///usr/share/sound/upgrade_later.mp3\",\"type\":1}
        ;;
esac
