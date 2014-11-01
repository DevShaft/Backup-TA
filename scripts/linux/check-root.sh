export BB=/data/local/tmp/busybox-backup-ta

SU=/system/bin/su
suPath=`adb shell $BB ls $SU`

if [[ $suPath =~ "No such" ]]
then
	SU=/system/xbin/su
	suPath=`adb shell $BB ls $SU`

	if [[ $suPath =~ "No such" ]]
	then	
		echo No su found. Did you install it on the phone yet ?
		exit 1
	fi
fi

rootPermission=`adb shell su -c "$BB echo xtrue"`

if [[ $rootPermission =~ "xtrue" ]]
then
	#echo "obtained root : $rootPermission"
	echo $SU
else
	echo "Failed to obtain root : $rootPermission"
	exit -1
fi