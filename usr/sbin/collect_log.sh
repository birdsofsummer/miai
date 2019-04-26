#!/bin/sh

LOG_TMP_FILE="/tmp/mico.log"
LOG_TAR_FILE="/tmp/log.tar.gz"
LOG_TAR_FILE_LOWMEM="/data/log/log.tar.gz"
CURR_LOG="/var/log/messages"
GZ_LOGS=""
CMCC_LOGS=""


do_collect_cmcc_log() {
	local CMCC_LOG_PATH="/tmp/cmcc/ims/"

	[ -d "$CMCC_LOG_PATH" ] || return 0
	ls $CMCC_LOG_PATH | grep -q "voip_" || return 0

	CMCC_LOGS="/tmp/cmcc/ims/voip*.log"
	return 0
}

do_collect_info() {
	echo "==========TOP info==========" >> $LOG_TMP_FILE
	top -b -n1 >> $LOG_TMP_FILE

	echo "==========ps info==========" >> $LOG_TMP_FILE
	ps -w >> $LOG_TMP_FILE

	echo "==========mem info==========" >> $LOG_TMP_FILE
	free >> $LOG_TMP_FILE

	echo "==========uptime===========" >> $LOG_TMP_FILE
	uptime >> $LOG_TMP_FILE

	echo "==========df -h==============" >> $LOG_TMP_FILE
	df -h >> $LOG_TMP_FILE

	echo "==========tmp dir==========" >> $LOG_TMP_FILE
	ls -lh /tmp/ >> $LOG_TMP_FILE
	du -sh /tmp/* >> $LOG_TMP_FILE

	echo "==========ifconfig==========" >> $LOG_TMP_FILE
	ifconfig >> $LOG_TMP_FILE

	echo "==========wifi info==========" >> $LOG_TMP_FILE
	wl status >> $LOG_TMP_FILE
	wpa_cli status >> $LOG_TMP_FILE
	wl rate >> $LOG_TMP_FILE

	echo "==========traceroute speech==========" >> $LOG_TMP_FILE
	traceroute -T -p 80 -w 1 speech.ai.xiaomi.com >> $LOG_TMP_FILE

	echo "==========meminfo=========" >> $LOG_TMP_FILE
	cat /proc/meminfo >> $LOG_TMP_FILE

	echo "==========dmesg===========:" >> $LOG_TMP_FILE
	dmesg >> $LOG_TMP_FILE
	echo "==========dmesg end===========:" >> $LOG_TMP_FILE

	[ -e /proc/slabinfo ] && {
		echo "==========slabinfo========"  >> $LOG_TMP_FILE
		cat /proc/slabinfo >> $LOG_TMP_FILE
	}

}

list_messages_gz(){
	for file in `ls /data/log/ | grep ^messages\.[0-5]\.gz$`; do
		GZ_LOGS=${GZ_LOGS}" /data/log/"${file}
		done
}

do_clean_up() {
	rm -f $LOG_TAR_FILE
	[ -f $LOG_TAR_FILE_LOWMEM ] && rm -f $LOG_TAR_FILE_LOWMEM
}

do_collect_log() {
	rm -f $LOG_TMP_FILE
	touch $LOG_TMP_FILE
	[ -f $LOG_TMP_FILE ] || {
		logger -s -p 1 -t logcollect "Failed to create temp log file"
		return
	}

	#hardware=`cat /proc/mico/model`

	do_collect_info
	list_messages_gz
	do_collect_cmcc_log

	FILELIST="$LOG_TMP_FILE $CURR_LOG $GZ_LOGS $CMCC_LOGS"

	# Are we low on memory?
	memfree=`cat /proc/meminfo  | grep MemFree | awk '{print $2}'`
	if [ "$memfree" -gt 2048 ]; then
		tar -zcf $LOG_TAR_FILE $FILELIST
	else
		tar -zcf $LOG_TAR_FILE_LOWMEM $FILELIST
		ln -s $LOG_TAR_FILE_LOWMEM $LOG_TAR_FILE
	fi

	rm -f $LOG_TMP_FILE
}

uploadfile_success()
{
    ubus call mibrain text_to_speech "{\"text\":\"日志上传成功\",\"save\":0}"
    exit 0
}


uploadfile_fail()
{
    ubus call mibrain text_to_speech "{\"text\":\"日志上传失败\",\"save\":0}"
    exit 1
}

case "$1" in
	collect)
		do_collect_log
		;;

	cleanup)
		do_clean_up
		;;
    mico_upload)        
        /usr/sbin/collect_log.sh collect || uploadfile_fail
        /usr/bin/matool_upload_log /tmp/log.tar.gz  || uploadfile_fail
        /usr/sbin/collect_log.sh cleanup
        uploadfile_success
        ;;
    cmcc_upload)
        /usr/bin/voip_helper -e uploadlog -v cmcc-ims || uploadfile_fail
        uploadfile_success
        ;;
	*)
		;;
esac

