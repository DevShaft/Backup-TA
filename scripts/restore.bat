call:%*
goto:eof

REM #####################
REM ## RESTORE
REM #####################
:restoreTA
echo.

choice /m "Are you sure you want to restore the TA Partition?"
if errorlevel 2 goto onRestoreCancelled

echo.

set /p restore_inputIMEI=Enter your IMEI:
set restore_inputIMEI=!restore_inputIMEI:~0,-1!

echo.
echo =======================================
echo  EXTRACT BACKUP
echo =======================================
tools\zip x -y backup\TA-backup.zip -otmpbak
if "%errorlevel%" neq "0" goto onRestoreFailed

echo.
echo =======================================
echo  INTEGRITY CHECK
echo =======================================
set /p restore_savedBackupMD5=<tmpbak\TA.md5
tools\md5 -l -n tmpbak\TA.img>tmpbak\restore_backupMD5.txt
if "%errorlevel%" neq "0" goto onRestoreFailed
set /p restore_backupMD5=<tmpbak\restore_backupMD5.txt
if NOT "%restore_savedBackupMD5%" == "%restore_backupMD5%" (
	echo FAILED
	goto onRestoreFailed
) else (
	echo OK
)

echo.
echo =======================================
echo  COMPARE TA PARTITION WITH BACKUP
echo =======================================
tools\adb shell su -c "md5sum %partition% | %bb% grep -o '^[^ ]*'">tmpbak\restore_currentPartitionMD5.txt
set /p restore_currentPartitionMD5=<tmpbak\restore_currentPartitionMD5.txt
if "%restore_currentPartitionMD5%" == "%restore_savedBackupMD5%" (
	echo TA partition already matches backup, no need to restore.
	goto onRestoreCancelled
) else (
	echo OK
)

echo.
echo =======================================
echo  BACKUP CURRENT TA PARTITION
echo =======================================
tools\adb shell su -c "dd if=%partition% of=/sdcard/revertTA.img"
if "%errorlevel%" neq "0" goto onRestoreFailed

echo.
echo =======================================
echo  PUSH BACKUP TO SDCARD
echo =======================================
tools\adb push tmpbak\TA.img sdcard/restoreTA.img
if "%errorlevel%" neq "0" goto onRestoreFailed

echo.
echo =======================================
echo  INTEGRITY CHECK
echo =======================================
tools\adb shell su -c "md5sum /sdcard/restoreTA.img | %bb% grep -o '^[^ ]*'">tmpbak\restore_pushedBackupMD5.txt
if "%errorlevel%" neq "0" goto onRestoreFailed
set /p restore_pushedBackupMD5=<tmpbak\restore_pushedBackupMD5.txt
if NOT "%restore_savedBackupMD5%" == "%restore_pushedBackupMD5%" (
	echo FAILED
	goto onRestoreFailed
) else (
	echo OK
)

echo.
echo =======================================
echo  IMEI CHECK
echo =======================================
tools\adb shell su -c "cat %partition% | %bb% grep -m 1 -o %restore_inputIMEI%">tmpbak\restore_partitionIMEI.txt
if "%errorlevel%" neq "0" goto onRestoreFailed
tools\adb shell su -c "cat /sdcard/restoreTA.img | %bb% grep -m 1 -o %restore_inputIMEI%">tmpbak\restore_backupIMEI.txt
if "%errorlevel%" neq "0" goto onRestoreFailed
set /p restore_partitionIMEI=<tmpbak\restore_partitionIMEI.txt
set /p restore_backupIMEI=<tmpbak\restore_backupIMEI.txt
if NOT "%restore_partitionIMEI%" == "%restore_backupIMEI%" (
	echo The backup appears to be from another device.
	choice /m "Are you sure you want to restore the TA Partition?"
	if errorlevel 2 goto onRestoreCancelled
) else (
	echo OK
)

echo.
echo =======================================
echo  RESTORE BACKUP
echo =======================================
tools\adb shell su -c "dd if=/sdcard/restoreTA.img of=%partition%"
if "%errorlevel%" neq "0" goto onRestoreFailed
tools\adb shell su -c "rm /sdcard/restoreTA.img"

echo.
echo =======================================
echo  COMPARE NEW TA PARTITION WITH BACKUP
echo =======================================
tools\adb shell su -c "md5sum %partition% | %bb% grep -o '^[^ ]*'">tmpbak\restore_restoredMD5.txt
set /p restore_restoredMD5=<tmpbak\restore_restoredMD5.txt
if "%restore_currentPartitionMD5%" == "%restore_restoredMD5%" (
	echo TA partition appears unchanged, try again.
	goto onRestoreFailed
) else if NOT "%restore_restoredMD5%" == "%restore_savedBackupMD5%" (
	echo TA partition seems corrupted. Trying to revert restore now...
	goto onRestoreCorrupt
) else (
	echo OK
)
goto onRestoreSuccess
goto:eof

REM #####################
REM ## RESTORE SUCCESS
REM #####################
:onRestoreSuccess
call:exit 1
goto:eof

REM #####################
REM ## RESTORE CANCELLED
REM #####################
:onRestoreCancelled
call:exit 2
goto:eof

REM #####################
REM ## RESTORE FAILED
REM #####################
:onRestoreFailed
call:exit 3
goto:eof

REM #####################
REM ## RESTORE CORRUPT
REM #####################
:onRestoreCorrupt
echo.
echo =======================================
echo  REVERT RESTORE
echo =======================================
tools\adb shell su -c "dd if=/sdcard/revertTA.img of=%partition%"

echo.
echo =======================================
echo  REVERT VERIFICATION
echo =======================================
tools\adb shell su -c "md5sum %partition% | %bb% grep -o '^[^ ]*'">tmpbak\restore_revertedMD5.txt
set /p restore_revertedMD5=<tmpbak\restore_revertedMD5.txt
if NOT "%restore_currentPartitionMD5%" == "%restore_revertedMD5%" (
	echo FAILED
	goto onRestoreRevertFailed
) else (
	echo OK
	goto onRestoreRevertSuccess
)
goto:eof

REM #####################
REM ## RESTORE REVERT FAILED
REM #####################
:onRestoreRevertFailed
tools\adb pull /sdcard/revertTA.img tmpbak\revertTA.img
call:exit 4
goto:eof

REM #####################
REM ## RESTORE REVERT SUCCESS
REM #####################
:onRestoreRevertSuccess
call:exit 5
goto:eof

REM #####################
REM ## EXIT RESTORE
REM #####################
:exit
if "%~1" == "1" call:dispose
if "%~1" == "3" call:dispose
echo.

if "%~1" == "1" echo *** Restore succesful. ***
if "%~1" == "2" echo *** Restore cancelled. ***
if "%~1" == "3" echo *** Restore unsuccesful. ***

if "%~1" == "4" echo *** DO NOT SHUTDOWN OR REBOOT DEVICE!!! ***
if "%~1" == "4" echo *** Reverting restore has failed! Contact DevShaft @XDA-forums for guidance. ***

if "%~1" == "5" echo *** Revert successful. Try to restore again. ***
pause
goto:eof

REM #####################
REM ## DISPOSE RESTORE
REM #####################
:dispose
set restore_backupMD5=
set restore_savedBackupMD5=
set restore_currentPartitionMD5=
set restore_pushedBackupMD5=
set restore_partitionIMEI=
set restore_backupIMEI=
set restore_restoredMD5=
set restore_revertedMD5=
set restore_inputIMEI=

tools\adb shell rm /sdcard/restoreTA.img > nul 2>&1
tools\adb shell rm /sdcard/revertTA.img > nul 2>&1
goto:eof