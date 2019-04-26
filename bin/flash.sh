#!/bin/sh
# flash.sh filename [silent] [no-reboot]


. /bin/boardupgrade.sh

upgrade_param_check() {
	if [ -z "$1" -o ! -f "$1" ]; then
		klogger "USAGE: $0 input.bin [1: slient] [1:don't reboot]"
		return 1
	fi

	board_upgrade_param_check
	if [ "$?" != "0" ]; then
		klogger "board upgrade param check failed"
		return 1
	fi

	if [ -f /usr/share/mico/version ]; then
		cur_ver=`cat /usr/share/mico/version | grep "option ROM" | awk '{ print $3 }'`
	else
		curr_ver="unknown version"
	fi
	klogger "Begin Ugrading..., current version: $cur_ver"
	echo 3 > /proc/sys/vm/drop_caches

	return 0
}

upgrade_prepare_dir() {
	absolute_path=`echo "$(cd "$(dirname "$1")"; pwd)/$(basename "$1")"`
	mount -o remount,size=80% /tmp
	rm -rf /tmp/system_upgrade
	mkdir -p /tmp/system_upgrade

	if [ ${absolute_path:0:4} = "/tmp" ]; then
		file_in_tmp=1
		mv $absolute_path /tmp/system_upgrade/
	else
		file_in_tmp=0
		cp $absolute_path /tmp/system_upgrade/
	fi
}

upgrade_done_set_flags() {

	# board specific upgrade subroutine should set this flag when only bootloader is upgraded
	[ -f /tmp/do_not_switch_os ] && return 0

	# set system ota upgrade flag 
	board_upgrade_done_set_flag

}

#check pid exist. prevent re-entry of flash.sh
upgrade_check_exist() {
	pid_file="/tmp/pid_xxxx"
	if [ -f $pid_file ]; then
		exist_pid=`cat $pid_file`
		if [ -n $exist_pid ]; then
			kill -0 $exist_pid 2>/dev/null
			if [ $? -eq 0 ]; then
				return 1
			else
				echo $$ > $pid_file
			fi
		else
			echo $$ > $pid_file
		fi
	else
		echo $$ > $pid_file
	fi

	return 0
}

upgrade_verify_image() {
	klogger -n "Verify Image: $1..."
	if [ -x /bin/miso ]; then
		miso -v "$1"
	else
		mkxqimage -r -v "$1"
	fi

	if [ "$?" = "0" ]; then
		klogger "Checksum OK"
		return 0
	else
		klogger "Checksum FAILED!"
		return 1
	fi
}

upgrade_check_exist
[ "$?" != "0" ] && {
	klogger "Upgrading, exit..."
	rm -f "$1"
	return 1
}


upgrade_param_check $1 $2 $3
[ "$?" != "0" ] && {
	rm -f "$1"
	klogger "Upgrade parameter check failed!"
	return 1
}

# image verification...
upgrade_verify_image $1
[ "$?" != "0" ] && {
	rm -f "$1"
	klogger "Upgrade parameter check failed!"
	return 1
}

# stop services
board_prepare_upgrade

# get silent flag
SILENT="$2"
if [ "$SILENT" = "1" ]; then
	klogger "Silent upgrading..."
else
	# if in silent mode, don't touch led
	board_start_upgrade_led
fi

# prepare to extract file
filename=`basename $1`
upgrade_prepare_dir $1
cd /tmp/system_upgrade

# start board-specific upgrading...
klogger "Begin Upgrading and Rebooting..."
board_system_upgrade $filename $2 $3
if [ "$?" != "0" ]; then
	rm -rf /tmp/system_upgrade
	klogger "Upgrade failed....."
	return 1
fi

# some board may reset after system upgrade and not reach here
# clean up
cd /
rm -rf /tmp/system_upgrade

upgrade_done_set_flags

if [ "$SILENT" = "1" ]; then
	[ -x /bin/silentboot.sh ] && {
		/bin/silentboot.sh set
		klogger "Silent boot flag set"
	}
fi

if [ "$3" = "1" ]; then
	klogger "Skip rebooting..."
	return 0
else
	klogger "Rebooting..."
	set_upgrade_status 'reboot'

	#force release ip before reboot
	killall -USR2 udhcpc
	reboot
fi
return 0
