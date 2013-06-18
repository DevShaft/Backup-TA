set restore_dryRun=
call:%*
goto:eof

REM #####################
REM ## RESTORE DRY
REM #####################
:restoreTAdry
set restore_dryRun=1
call:restoreTA
goto:eof

REM #####################
REM ## RESTORE
REM #####################
:restoreTA
echo.
call scripts\adb.bat wakeDevice
echo.
if "%restore_dryRun%" == "1" (
	echo --- Restore dry run ---
	echo.
)

set restore_inputIMEI=
set /p restore_inputIMEI=Enter your IMEI (digits only): 
set restore_inputIMEILen=
call scripts\string-util.bat strlen restore_inputIMEILen restore_inputIMEI
if NOT "%restore_inputIMEILen%" == "15" goto onRestoreInvalidIMEI
set restore_inputIMEILen=
setlocal enabledelayedexpansion
set restore_inputIMEI=!restore_inputIMEI:~0,-1!
setlocal disabledelayedexpansion
verify > nul

tools\adb get-serialno>tmpbak\restore_serialno
set /p restore_serialno=<tmpbak\restore_serialno

echo.
echo =======================================
echo  CHOOSE BACKUP TO RESTORE
echo =======================================
setLocal enabledelayedexpansion
echo off > tmpbak\restoreList
set restore_restoreIndex=0
for /f "tokens=*" %%D in ('dir/b backup\TA-Backup*.zip') do (
	set /a restore_restoreIndex+=1
	echo [!restore_restoreIndex!] %%D >> tmpbak\restoreList
)
echo [Q] Quit >> tmpbak\restoreList
type tmpbak\restoreList

:restoreChoose
set /p restore_restoreChosen=Please make your decision:

if "%restore_restoreChosen%" == "q"	goto onRestoreCancelled
if "%restore_restoreChosen%" == "Q" goto onRestoreCancelled

tools\find "[!restore_restoreChosen!]" < tmpbak\restoreList > tmpbak\restoreItem
for /f "tokens=2" %%T in (tmpbak\restoreItem) do (
	set restore_restoreFile=%%T 
)
if "%restore_restoreFile%" == "" goto restoreChoose
setlocal disabledelayedexpansion
 
echo.
%choice% /c:yn %choiceTextParam% "Are you sure you want to restore the TA Partition?"
if errorlevel 2 goto onRestoreCancelled
 
echo.
echo =======================================
echo  EXTRACT BACKUP
echo =======================================
tools\zip x -y backup\%restore_restoreFile% -otmpbak
if NOT "%errorlevel%" == "0" goto onRestoreFailed

echo.
echo =======================================
echo  INTEGRITY CHECK
echo =======================================
set /p restore_savedBackupMD5=<tmpbak\TA.md5
verify > nul
call scripts\string-util.bat strlen restore_savedBackupMD5Len restore_savedBackupMD5
set /a restore_savedBackupMD5TrailingSpaces=%restore_savedBackupMD5Len%-32
setlocal enabledelayedexpansion
for /f "tokens=* delims= " %%a in ("%restore_savedBackupMD5%") do set restore_savedBackupMD5=%%a
for /l %%a in (1,1,100) do if "!restore_savedBackupMD5:~-1!"==" " set restore_savedBackupMD5=!restore_savedBackupMD5:~0,-%restore_savedBackupMD5TrailingSpaces%!
setlocal disabledelayedexpansion
tools\md5 -l -n tmpbak\TA.img>tmpbak\restore_backupMD5
if NOT "%errorlevel%" == "0" goto onRestoreFailed
set /p restore_backupMD5=<tmpbak\restore_backupMD5
verify > nul
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
tools\adb shell su -c "%bb% md5sum %partition% | %bb% grep -o '^[^ ]*'">tmpbak\restore_currentPartitionMD5
set /p restore_currentPartitionMD5=<tmpbak\restore_currentPartitionMD5
verify > nul
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
tools\adb shell su -c "%bb% dd if=%partition% of=/sdcard/revertTA.img && %bb% sync && %bb% sync && %bb% sync && %bb% sync"
if NOT "%errorlevel%" == "0" goto onRestoreFailed

echo.
echo =======================================
echo  PUSH BACKUP TO SDCARD
echo =======================================
tools\adb push tmpbak\TA.img sdcard/restoreTA.img
if NOT "%errorlevel%" == "0" goto onRestoreFailed

echo.
echo =======================================
echo  INTEGRITY CHECK
echo =======================================
tools\adb shell su -c "%bb% md5sum /sdcard/restoreTA.img | %bb% grep -o '^[^ ]*'">tmpbak\restore_pushedBackupMD5
if NOT "%errorlevel%" == "0" goto onRestoreFailed
set /p restore_pushedBackupMD5=<tmpbak\restore_pushedBackupMD5
verify > nul
if NOT "%restore_savedBackupMD5%" == "%restore_pushedBackupMD5%" (
	echo FAILED
	goto onRestoreFailed
) else (
	echo OK
)

echo.
echo =======================================
echo  IMEI / SERIAL CHECK
echo =======================================
tools\adb shell su -c "%bb% cat %partition% | %bb% grep -m 1 -o %restore_inputIMEI%">tmpbak\restore_partitionIMEI
if NOT "%errorlevel%" == "0" goto onRestoreFailed
tools\adb shell su -c "%bb% cat /sdcard/restoreTA.img | %bb% grep -m 1 -o %restore_inputIMEI%">tmpbak\restore_backupIMEI
if NOT "%errorlevel%" == "0" goto onRestoreFailed
tools\adb shell su -c "%bb% cat /sdcard/restoreTA.img | %bb% grep -m 1 -o %restore_serialno%">tmpbak\restore_backupSerial
if NOT "%errorlevel%" == "0" goto onRestoreFailed
set /p restore_partitionIMEI=<tmpbak\restore_partitionIMEI
set /p restore_backupIMEI=<tmpbak\restore_backupIMEI
set /p restore_backupSerial=<tmpbak\restore_backupSerial
verify > nul
if NOT "%restore_partitionIMEI%" == "%restore_backupIMEI%" (
	goto otherDevice
) else if NOT "%restore_serialno%" == "%restore_backupSerial%" (
	goto otherDevice
)
echo OK
goto validDevice

:otherDevice
echo The backup appears to be from another device.
%choice% /c:yn %choiceTextParam% "Are you sure you want to restore the TA Partition?"
if errorlevel 2 goto onRestoreCancelled

:validDevice
echo.
echo =======================================
echo  RESTORE BACKUP
echo =======================================
if NOT "%restore_dryRun%" == "1" (
	tools\adb shell su -c "%bb% dd if=/sdcard/restoreTA.img of=%partition% && %bb% sync && %bb% sync && %bb% sync && %bb% sync"
	if NOT "%errorlevel%" == "0" goto onRestoreFailed
) else (
	echo --- dry run ---
)
tools\adb shell su -c "rm /sdcard/restoreTA.img"

echo.
echo =======================================
echo  COMPARE NEW TA PARTITION WITH BACKUP
echo =======================================
tools\adb shell su -c "%bb% md5sum %partition% | %bb% grep -o '^[^ ]*'">tmpbak\restore_restoredMD5
if NOT "%restore_dryRun%" == "1" (
	set /p restore_restoredMD5=<tmpbak\restore_restoredMD5
	verify > nul
) else (
	set restore_restoredMD5=%restore_pushedBackupMD5%
)
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
REM ## RESTORE INVALID IMEI
REM #####################
:onRestoreInvalidIMEI
echo Invalid IMEI provided.
goto onRestoreCancelled
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
if NOT "%restore_dryRun%" == "1" (
	tools\adb shell su -c "%bb% dd if=/sdcard/revertTA.img of=%partition% && %bb% sync && %bb% sync && %bb% sync && %bb% sync"
)

echo.
echo =======================================
echo  REVERT VERIFICATION
echo =======================================
tools\adb shell su -c "%bb% md5sum %partition% | %bb% grep -o '^[^ ]*'">tmpbak\restore_revertedMD5
if NOT "%restore_dryRun%" == "1" (
	set /p restore_revertedMD5=<tmpbak\restore_revertedMD5
) else (
	set /p restore_revertedMD5=%restore_currentPartitionMD5%
)
verify > nul
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

if "%~1" == "1" echo *** Restore successful. ***
if "%~1" == "2" echo *** Restore cancelled. ***
if "%~1" == "3" echo *** Restore unsuccessful. ***

if "%~1" == "4" echo *** DO NOT SHUTDOWN OR REBOOT DEVICE!!! ***
if "%~1" == "4" echo *** Reverting restore has failed! Contact DevShaft @XDA-forums for guidance. ***

if "%~1" == "5" echo *** Revert successful. Try to restore again. ***
echo.
pause
goto:eof

REM #####################
REM ## DISPOSE RESTORE
REM #####################
:dispose
set restore_dryRun=
set restore_backupMD5=
set restore_savedBackupMD5=
set restore_currentPartitionMD5=
set restore_pushedBackupMD5=
set restore_partitionIMEI=
set restore_backupIMEI=
set restore_restoredMD5=
set restore_revertedMD5=
set restore_inputIMEI=
set restore_inputIMEILen=
set restore_backupSerial=

tools\adb shell rm /sdcard/restoreTA.img > nul 2>&1
tools\adb shell rm /sdcard/revertTA.img > nul 2>&1
goto:eof