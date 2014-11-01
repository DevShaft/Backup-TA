PARTITION_BY_NAME=/dev/block/platform/msm_sdcc.1/by-name/TA

root=`./check-root.sh`

#if not root, exit
if [ "$root" == "" ]
then 
	echo "not rooted"
	exit 1
fi


echo  FIND TA PARTITION

backup_defaultTA=`adb shell su -c "$BB ls -l $PARTITION_BY_NAME | $BB awk '{print \$11}'"`
backup_defaultTAvalid=`adb shell su -c "if [ -b '!backup_defaultTA!' ]; then echo '1'; else echo '0'; fi"`

echo backup_defaultTA $backup_defaultTA
echo backup_defaultTAvalid $backup_defaultTAvalid

echo debug exit
exit 1

if "!backup_defaultTAvalid!" == "1" (
	set partition=!backup_defaultTA!
	echo Partition found^^!
) else (
	echo Partition not found by name.
	echo.
	%CHOICE% /c:yn %CHOICE_TEXT_PARAM% "Do you want to perform an extensive search for the TA?"
	if "!errorlevel!" == "2" goto onBackupCancelled
	
	echo.
	echo =======================================
	echo  INSPECTING PARTITIONS
	echo =======================================
	set backup_taPartitionName=
	adb shell su -c "%BB% cat /proc/partitions | %BB% awk '{if (\$3<=9999 && match (\$4, \"'\"mmcblk\"'\")) print \$4}'">tmpbak\backup_potentialPartitions
	for /F "tokens=*" %%A in (tmpbak\backup_potentialPartitions) do call:inspectPartition %%A
	
	if NOT "!backup_taPartitionName!" == "" (
		if NOT "!backup_taPartitionName!" == "-1" (
			echo Partition found^^!
			set partition=/dev/block/!backup_taPartitionName!
		) else (
				echo *** More than one partition match the TA partition search criteria. ***
				echo *** Therefore it is not possible to determine which one or ones to use. ***
				echo *** Contact DevShaft @XDA-forums for support. ***
			goto onBackupCancelled
		)
	) else (
		echo *** No compatible TA partition found on your device. ***
		goto onBackupCancelled
	)
	
)