#!/bin/bash 

TMP=../../tmpbak

sudo adb kill-server
sudo adb start-server
adb wait-for-device 

./busybox-on.sh

touch /tmp/partfile
./find.sh
partition=`cat /tmp/partfile`
rm /tmp/partfile

echo =======================================
echo  FIND TA PARTITION
echo =======================================
echo partition $partition

if [[ $partition == "" ]]
then
	echo No partition found
	exit -1
fi

echo =======================================
echo  BACKUP TA PARTITION
echo =======================================
backup_currentPartitionMD5=`adb shell su -c "$BB md5 $partition" | awk {'print $1'}`
adb shell su -c "$BB dd if=$partition of=/sdcard/backupTA.img"

echo
echo =======================================
echo  INTEGRITY CHECK
echo =======================================
backup_backupMD5=`adb shell su -c "$BB md5 /sdcard/backupTA.img" | awk {'print $1'}`

if [ "$backup_currentPartitionMD5" != "$backup_backupMD5" ]
then
	echo FAILED - Backup does not match TA Partition. Please try again.
	echo $backup_currentPartitionMD5
	echo $backup_backupMD5
	exit 1
fi

if [ -d $TMP ]
then
	mkdir $TMP
fi

echo 
echo =======================================
echo  PULL BACKUP FROM SDCARD
echo =======================================
adb pull /sdcard/backupTA.img $TMP/TA.img

echo 
echo =======================================
echo  INTEGRITY CHECK
echo =======================================
localmd5=`md5sum $TMP/TA.img | awk {'print $1'} `

if [ "$localmd5" != "$backup_backupMD5" ]
then
	echo FAILED - Backup has gone corrupted while pulling. Please try again.
	echo $backup_currentPartitionMD5
	echo $backup_backupMD5
	echo $localmd5
	exit 1
fi

echo 
echo =======================================
echo  PACKAGE BACKUP
echo =======================================
serial=`adb get-serialno`

cd $TMP

backup_timestamp=`date +%Y-%m-%d.%H%M%S`
echo $backup_backupMD5 > TA.md5
echo $partition > TA.blk
echo $serial > TA.serial
echo $backup_timestamp > TA.timestamp
echo $1 > TA.version
uname -sp > TA.platform

zip ../TA-backup-$backup_timestamp.zip TA.img TA.md5 TA.blk TA.serial TA.timestamp TA.version TA.platform

cd ..

rm -rf $TMP

./scripts/linux/busybox-off.sh