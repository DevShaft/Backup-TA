PARTITION_BY_NAME=/dev/block/platform/msm_sdcc.1/by-name/TA

root=`./check-root.sh`

#if not rooted, exit
if [ "$root" == "" ]
then 
	echo "not rooted"
	exit 1
fi

backup_defaultTA=`adb shell su -c "$BB ls -l --color=never $PARTITION_BY_NAME" | tr -s ' ' | awk '{print $11}'`
backup_defaultTAvalid=`adb shell su -c "if [ -b $backup_defaultTA ]; then echo '1'; else echo '0'; fi"`
#TODO works by hand !
#$ adb shell su -c "if [ -b /dev/block/mmcblk0p1 ]; then echo '1'; else echo '0'; fi"
#1


echo backup_defaultTA $backup_defaultTA
echo backup_defaultTAvalid $backup_defaultTAvalid

echo debug exit
exit 1

if "!backup_defaultTAvalid!" == "1" (
	echo $backup_defaultTA
) else (
	echo Partition not found by name.
	echo No support yet for finding by other methods
	exit 1
)