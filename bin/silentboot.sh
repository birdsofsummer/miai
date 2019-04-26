#!/bin/sh
#


silent_flag_set() {
	/bin/fw_setenv silent_boot 1 > /dev/null 2>&1
}

silent_flag_get() {
	val=`/bin/fw_printenv -n silent_boot`
	if [ "$val" = "1" ]; then
		echo "1"
	else
		echo "0"
	fi
}

silent_flag_clear() {
	/bin/fw_setenv silent_boot 0 > /dev/null 2>&1
}


case "$1" in
	"set")
		silent_flag_set
		;;
	"get")
		silent_flag_get
		;;
	"clear")
		silent_flag_clear
		;;
	"*")
		;;
esac
