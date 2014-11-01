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
adb shell su -c "%BB% md5sum !partition! | %BB% awk {'print \$1'}">tmpbak\backup_currentPartitionMD5
adb shell su -c "%BB% dd if=!partition! of=/sdcard/backupTA.img"

echo.
echo =======================================
echo  INTEGRITY CHECK
echo =======================================
adb shell su -c "%BB% md5sum /sdcard/backupTA.img | %BB% awk {'print \$1'}">tmpbak\backup_backupMD5
set /p backup_currentPartitionMD5=<tmpbak\backup_currentPartitionMD5
set /p backup_backupMD5=<tmpbak\backup_backupMD5
verify > nul
if NOT "!backup_currentPartitionMD5!" == "!backup_backupMD5!" (
	echo FAILED - Backup does not match TA Partition. Please try again.
	goto onBackupFailed
) else (
	echo OK
)

echo.
echo =======================================
echo  PULL BACKUP FROM SDCARD
echo =======================================
adb pull /sdcard/backupTA.img tmpbak\TA.img
if NOT "!errorlevel!" == "0" goto onBackupFailed

echo.
echo =======================================
echo  INTEGRITY CHECK
echo =======================================
tools\md5.exe -l -n tmpbak\TA.img>tmpbak\backup_backupPulledMD5
if NOT "!errorlevel!" == "0" goto onBackupFailed
set /p backup_backupPulledMD5=<tmpbak\backup_backupPulledMD5
verify > nul
if NOT "!backup_currentPartitionMD5!" == "!backup_backupPulledMD5!" (
	echo FAILED - Backup has gone corrupted while pulling. Please try again.
	goto onBackupFailed
) else (
	echo OK
)

echo.
echo =======================================
echo  PACKAGE BACKUP
echo =======================================
adb get-serialno>tmpbak\TA.serial
echo !partition!>tmpbak\TA.blk
echo !backup_backupPulledMD5!>tmpbak\TA.md5
echo %VERSION%>tmpbak\TA.version
adb shell su -c "%BB% date +%%Y%%m%%d.%%H%%M%%S">tmpbak\TA.timestamp
set /p backup_timestamp=<tmpbak\TA.timestamp
cd tmpbak
..\tools\zip.exe a ..\backup\TA-backup-!backup_timestamp!.zip TA.img TA.md5 TA.blk TA.serial TA.timestamp TA.version
if NOT "!errorlevel!" == "0" goto onBackupFailed