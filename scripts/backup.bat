call:%*
goto:eof

REM #####################
REM ## BACKUP
REM #####################
:backupTA
echo.

if NOT exist backup mkdir backup > nul 2>&1

echo.
echo =======================================
echo  BACKUP TA PARTITION
echo =======================================
tools\adb shell su -c "%bb% md5sum %partition% | %bb% grep -o '^[^ ]*'">tmpbak\backup_currentPartitionMD5.txt
tools\adb shell su -c "%bb% dd if=%partition% of=/sdcard/backupTA.img"

echo.
echo =======================================
echo  INTEGRITY CHECK
echo =======================================
tools\adb shell su -c "%bb% md5sum /sdcard/backupTA.img | %bb% grep -o '^[^ ]*'">tmpbak\backup_backupMD5.txt
set /p backup_currentPartitionMD5=<tmpbak\backup_currentPartitionMD5.txt
set /p backup_backupMD5=<tmpbak\backup_backupMD5.txt
verify > nul
if NOT "%backup_currentPartitionMD5%" == "%backup_backupMD5%" (
	echo FAILED
	goto onBackupFailed
) else (
	echo OK
)

echo.
echo =======================================
echo  PULL BACKUP FROM SDCARD
echo =======================================
tools\adb pull /sdcard/backupTA.img tmpbak\TA.img
if NOT "%errorlevel%" == "0" goto onBackupFailed

echo.
echo =======================================
echo  INTEGRITY CHECK
echo =======================================
tools\md5 -l -n tmpbak\TA.img>tmpbak\backup_backupPulledMD5.txt
if NOT "%errorlevel%" == "0" goto onBackupFailed
set /p backup_backupPulledMD5=<tmpbak\backup_backupPulledMD5.txt
verify > nul
if NOT "%backup_currentPartitionMD5%" == "%backup_backupPulledMD5%" (
	echo FAILED
	goto onBackupFailed
) else (
	echo OK
)

echo.
echo =======================================
echo  PACKAGE BACKUP
echo =======================================
echo %backup_backupPulledMD5%>tmpbak\TA.md5
cd tmpbak
call ..\scripts\date-util.bat getDateTime backup_timestamp
..\tools\zip a ..\backup\TA-backup-%backup_timestamp%.zip TA.img TA.md5
if NOT "%errorlevel%" == "0" goto onBackupFailed
cd..

call:exit 1
goto:eof

REM #####################
REM ## BACKUP CANCELLED
REM #####################
:onBackupCancelled
call:exit 2
goto:eof

REM #####################
REM ## BACKUP FAILED
REM #####################
:onBackupFailed
call:exit 3
goto:eof

REM #####################
REM ## EXIT BACKUP
REM #####################
:exit
call:dispose
echo.
if "%~1" == "1" echo *** Backup succesful. ***
if "%~1" == "2" echo *** Backup cancelled. ***
if "%~1" == "3" echo *** Backup unsuccesful. ***
pause
goto:eof

REM #####################
REM ## DISPOSE BACKUP
REM #####################
:dispose
set backup_currentPartitionMD5=
set backup_backupMD5=
set backup_backupPulledMD5=

tools\adb shell rm /sdcard/backupTA.img > nul 2>&1
goto:eof