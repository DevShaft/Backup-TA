sudo adb kill-server
sudo adb start-server
adb wait-for-device 

./busybox-on.sh

partition=`./find.sh`

#if empty, abort

./busybox-off.sh
#debug
exit -1

echo =======================================
echo  BACKUP TA PARTITION
echo =======================================
backup_currentPartitionMD5=`adb shell su -c "$BB md5 $partition" | awk {'print $1'}`
adb shell su -c "$BB dd if=$partition of=/sdcard/backupTA.img"

echo
echo =======================================
echo  INTEGRITY CHECK
echo =======================================
backup_backupMD5=`adb shell su -c "$BB md5 /sdcard/backupTA.img" | awk {'print $1'}

if [ "$backup_currentPartitionMD5" != "$backup_backupMD5" ]
then
	echo FAILED - Backup does not match TA Partition. Please try again.
	echo $backup_currentPartitionMD5
	echo $backup_backupMD5
	exit 1
fi

echo 
echo =======================================
echo  PULL BACKUP FROM SDCARD
echo =======================================
adb pull /sdcard/backupTA.img tmpbak\TA.img

echo 
echo =======================================
echo  INTEGRITY CHECK
echo =======================================
localmd5=`md5sum tmpbak\TA.img`

if [ "$localmd5" != "$backup_backupPulledMD5" ]
then
	echo FAILED - Backup has gone corrupted while pulling. Please try again.
	exit 1
fi

echo 
echo =======================================
echo  PACKAGE BACKUP
echo =======================================
serial=`adb get-serialno`

cd tmpbak
echo TODO ..\tools\zip.exe a ..\backup\TA-backup-!backup_timestamp!.zip TA.img TA.md5 TA.blk TA.serial TA.timestamp TA.version
