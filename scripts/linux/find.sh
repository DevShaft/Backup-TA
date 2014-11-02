#!/bin/bash 

PARTITION_BY_NAME=/dev/block/platform/msm_sdcc.1/by-name/TA

root=`./check-root.sh`

#if not rooted, exit
if [ "$root" == "" ]
then 
	echo "not rooted"
	exit 1
fi

backup_defaultTA=`adb shell su -c "$BB ls -l --color=never $PARTITION_BY_NAME" | tr -s ' ' | awk '{print $11}' `
#remove invalid head/tail chars
backup_defaultTA=`expr match "$backup_defaultTA" '\([0-9a-z\/]*\)'`
backup_defaultTAvalid=`adb shell su -c "if [ -b $backup_defaultTA ]; then echo '1'; else echo '0'; fi"`

if [[ $backup_defaultTA != /* ]]
then
	echo Partition not found by name.
	echo $backup_defaultTA
	echo No support yet for finding by other methods
	exit 1
fi

if [[ "$backup_defaultTAvalid" =~ "1" ]]
then
	echo $backup_defaultTA
else
	echo Partition found but not valid
	echo backup_defaultTA $backup_defaultTA
	echo backup_defaultTAvalid $backup_defaultTAvalid
	echo No support yet for finding by other methods
	exit 1
fi