#!/bin/sh
#

klogger(){
	local msg1="$1"
	local msg2="$2"

	if [ "$msg1" = "-n" ]; then
		echo  -n "$msg2" >> /dev/kmsg 2>/dev/null
	else
		echo "$msg1" >> /dev/kmsg 2>/dev/null
	fi

	return 0
}

stop_service(){
	echo 3 > /proc/sys/vm/drop_caches
}

restore_service(){
	return
}

upker() {
	local dev="/dev/mtd"$kernel_mtd_target""

	mtd write boot.img "$dev" >& /dev/null
	if [ $? -eq 0 ]; then
		klogger "Done"
		return 0
	fi

	# kernel upgrade failed.
	restore_service
	return 1
}

upboot() {
	flash_erase /dev/mtd0 0 8
	dd if=u-boot.bin of=/dev/mtd0 bs=1M count=1
	return 0
}

upfs_ubi() {

	local dev="/dev/mtd"$rootfs_mtd_target""
	local devn=2

	# First, get length of uncompressed file length, which is 8 byte long at offset=5. We only need 4 bytes.
	dd if=root.ubi.lzma of=len.bin bs=1 count=4 skip=5 2&>1 > /dev/null
	len=`hexdump -e '1/4 "%d"' len.bin`
	[ -z "$len" ] && {
		klogger "Unable to get image length"
		return 1
	}

	klogger "Burning $dev rootfs Block, image length "$len""
	unlzma -c root.ubi.lzma | ubiformat "$dev" -s 2048 -O 2048 -S "$len" -y -f -
	klogger "Done"

	klogger "Verify burning..."
	# Try attach the device
	ubiattach /dev/ubi_ctrl -d "$devn" -O 2048 -p "$dev"
	if [ "$?" = "0" ]; then
		klogger "PASSED"
		ubidetach -d "$devn"
	else
		#reformat
		klogger "FAILED! Reformat..."
		mtd erase "$dev"
		unlzma -c root.ubi.lzma | ubiformat "$dev" -s 2048 -O 2048 -S "$len" -y -f -

		klogger "Verify burning..."
		ubiattach /dev/ubi_ctrl -d "$devn" -O 2048 -p "$dev"
		[ "$?" = "0" ] || {
			klogger "Failed again!"
			return 1
		}
	fi

}

board_upgrade_param_check() {
	return 0
}

board_upgrade_done_set_flag() {
	#upgrade success. set flags

	if [ "$rootfs_mtd_current" -gt "$rootfs_mtd_target" ]; then
	    /bin/fw_setenv boot_part boot0
	else
	    /bin/fw_setenv boot_part boot1
	fi

	return 0
}


board_prepare_upgrade() {
	stop_service
}

board_start_upgrade_led() {
	return
}


board_system_upgrade() {
	local filename=$1
	uboot_mtd=$(grep nandboot /proc/mtd | awk -F: '{print substr($1,4)}')

	kernel0_mtd=$(grep boot0 /proc/mtd | awk -F: '{print substr($1,4)}')
	kernel1_mtd=$(grep boot1 /proc/mtd | awk -F: '{print substr($1,4)}')

	rootfs0_mtd=$(grep system0 /proc/mtd | awk -F: '{print substr($1,4)}')
	rootfs1_mtd=$(grep system1 /proc/mtd | awk -F: '{print substr($1,4)}')

	rootfs_mtd_current=$(cat /sys/class/ubi/ubi0/mtd_num)
	rootfs_mtd_target=$(($rootfs0_mtd+$rootfs1_mtd-$rootfs_mtd_current))

	kernel_mtd_current=$(($rootfs_mtd_current-2))
	kernel_mtd_target=$(($kernel0_mtd+$kernel1_mtd-$kernel_mtd_current))

	mkxqimage -r -x $filename
	[ "$?" = "0" ] || {
		klogger "cannot extract files"
		rm -rf $filename
		return 1
	}
	rm -f $filename

	# disable bootloader upgrade per ligeng requested
	#[ -f u-boot.bin ] && upboot

	[ -f boot.img ] && {
		upker || return 1
	}

	[ -f root.ubi.lzma ] && {
		upfs_ubi || return 1
	}

	return 0
}
