@echo off
set partition=/dev/block/mmcblk0p1
cls
echo  ----------------------------------
echo  [  by Ricky Wyatt and Egan @xda  ]
echo  ----------------------------------
echo  [ Use this tool at your own risk ]
echo  [      We will not take and      ]
echo  [         responsibility         ]
echo  [    if you brick your phone     ]
echo  ----------------------------------
pause
cls
cd %~dp0
set /p "=Waiting for device..." < nul
tools\adb wait-for-device > nul
echo OK
mkdir tmpbak > nul 2>&1
mkdir backup > nul 2>&1
set hasBusyBox=0
tools\adb shell grep -q '$' /system/build.prop;echo $? > tmpbak\hasBusyBox.txt
for /f %%a in (tmpbak\hasBusyBox.txt) do (
	if %hasBusyBox% == 0 (
		set hasBusyBox=%%a
	)
)
tools\adb shell cat /dev/null;echo $? > tmpbak\hasBusyBox.txt
for /f %%a in (tmpbak\hasBusyBox.txt) do (
	if %hasBusyBox% == 0 (
		set hasBusyBox=%%a
	)
)
tools\adb shell md5sum /dev/null;echo $? > tmpbak\hasBusyBox.txt
for /f %%a in (tmpbak\hasBusyBox.txt) do (
	if %hasBusyBox% == 0 (
		set hasBusyBox=%%a
	)
)
tools\adb shell dd if=/dev/null of=/dev/null;echo $? > tmpbak\hasBusyBox.txt
for /f %%a in (tmpbak\hasBusyBox.txt) do (
	if %hasBusyBox% == 0 (
		set hasBusyBox=%%a
	)
)

if NOT %hasBusyBox% == 0 (
	echo Busybox not installed or incompatible version.
	goto quit
)

del /q tmpbak\*.*

:main
set menunr=
mkdir tmpbak > nul 2>&1
cls
echo  ----------------------------------
echo  [   Backup and Restore TA v7.7   ]
echo  ----------------------------------
echo  [ (1) Backup                     ]
echo  [ (2) Restore                    ]
echo  [ (3) Convert v4 backup          ]
echo  [ (4) Quit                       ]
echo  ----------------------------------
choice /c:1234 /m "Please make your decision:"
IF %errorlevel%==1 (goto backup)
IF %errorlevel%==2 (goto restore)
IF %errorlevel%==3 (goto convert)
IF %errorlevel%==4 (goto quit)
goto quit

REM #####################
REM ## BACKUP
REM #####################
:backup
echo.
echo =======================================
echo  BACKUP TA PARTITION
echo =======================================
tools\adb shell su -c "dd if=%partition% of=/sdcard/TA.img"

echo.
echo =======================================
echo  GENERATE MD5 HASH OF TA PARTITION
echo =======================================
tools\adb shell su -c "md5sum %partition% | grep -o '^[^ ]*'" > tmpbak\origMD5.txt
set /p origMD5=<tmpbak\origMD5.txt
echo MD5: %origMD5%

echo.
echo =======================================
echo  GENERATE MD5 HASH OF BACKUP ON SDCARD
echo =======================================
tools\adb shell su -c "md5sum /sdcard/TA.img | grep -o '^[^ ]*'" > tmpbak\backupMD5sdcard.txt
set /p backupMD5sdcard=<tmpbak\backupMD5sdcard.txt
echo MD5: %backupMD5sdcard%

echo.
echo =======================================
echo  COMPARE MD5 HASHES 1/2
echo =======================================
echo Original MD5: %origMD5%
echo Backup MD5: %backupMD5sdcard%
if NOT "%origMD5%" == "%backupMD5sdcard%" (
	echo MD5 hashes do not match.
	goto bakfail
)

echo.
echo =======================================
echo  PULL BACKUP FROM SDCARD
echo =======================================
tools\adb pull /sdcard/TA.img tmpbak\TA.img
if NOT "%errorlevel%" == "0" goto bakfail

echo.
echo =======================================
echo  GENERATE MD5 HASH OF PULLED BACKUP
echo =======================================
tools\md5 -l -n tmpbak\TA.img > tmpbak\backupMD5.txt
if NOT "%errorlevel%" == "0" goto bakfail
set /p backupMD5=<tmpbak\backupMD5.txt

echo.
echo =======================================
echo  COMPARE MD5 HASHES 2/2
echo =======================================
echo Original MD5: %origMD5%
echo Backup MD5: %backupMD5%
if NOT "%origMD5%" == "%backupMD5%" (
	echo MD5 hashes do not match.
	goto bakfail
)

echo.
echo =======================================
echo  PACKAGE BACKUP
echo =======================================
mkdir backup
echo %backupMD5% > tmpbak\TA.md5
cd tmpbak
..\tools\zip a ..\backup\TA-backup.zip TA.img TA.md5
if NOT "%errorlevel%" == "0" goto bakfail
cd..

echo.
echo =======================================
echo  CLEAN UP
echo =======================================
del /q /s tmpbak\*.*
set origMD5=
set backupMD5sdcard=
set backupMD5=

echo.
echo *** Backup was succesful! ***
goto restart

REM #####################
REM ## BACKUP FAILED
REM #####################
:bakfail
echo.
echo =======================================
echo  CLEAN UP
echo =======================================
del /q /s tmpbak\*.*
set origMD5=
set backupMD5sdcard=
set backupMD5=

echo.
echo *** Backup was unsuccesful. ***
goto restart

REM #####################
REM ## RESTORE
REM #####################
:restore
echo.

choice /m "Are you sure you want to restore the TA Partition?"
if errorlevel 2 goto restcancel

echo.

set /p imei=Enter your IMEI:
set imei=!imei:~0,-1!

echo.
echo =======================================
echo  EXTRACT BACKUP
echo =======================================
tools\zip x -y backup\TA-backup.zip -otmpbak
if "%errorlevel%" neq "0" goto restfail

echo.
echo =======================================
echo  COMPARE MD5 HASHES 1/2
echo =======================================
set /p origMD5=<tmpbak\TA.md5
tools\md5 -l -n tmpbak\TA.img > tmpbak\backupMD5.txt
if "%errorlevel%" neq "0" goto restfail
set /p backupMD5=<tmpbak\backupMD5.txt
echo Original MD5: %origMD5%
echo Backup MD5: %backupMD5%
if NOT "%origMD5%" == "%backupMD5%" (
	echo MD5 hashes do not match.
	goto restfail
)

echo.
echo =======================================
echo  PUSH BACKUP TO SDCARD
echo =======================================
tools\adb push tmpbak\TA.img sdcard/TA.img
if "%errorlevel%" neq "0" goto restfail

echo.
echo =======================================
echo  COMPARE MD5 HASHES 2/2
echo =======================================
tools\adb shell su -c "md5sum /sdcard/TA.img | grep -o '^[^ ]*'" > tmpbak\backupMD5sdcard.txt
set /p backupMD5sdcard=<tmpbak\backupMD5sdcard.txt
echo Original MD5: %origMD5%
echo Backup MD5: %backupMD5sdcard%
if NOT "%origMD5%" == "%backupMD5sdcard%" (
	echo MD5 hashes do not match.
	goto restfail
)

echo.
echo =======================================
echo  COMPARE IMEI
echo =======================================
tools\adb shell su -c "cat %partition% | grep -m 1 -o %imei%" > tmpbak\imeipartfound.txt
tools\adb shell su -c "cat /sdcard/TA.img | grep -m 1 -o %imei%" > tmpbak\imeibackupfound.txt
set /p imeipartfound=<tmpbak\imeipartfound.txt
set /p imeibackupfound=<tmpbak\imeibackupfound.txt
echo Current TA IMEI: %imeipartfound%
echo Backup TA IMEI: %imeibackupfound%
if NOT "%imeipartfound%" == "%imeibackupfound%" (
	echo The backup appears to be from another device.
	choice /m "Are you sure you want to restore the TA Partition?"
	if errorlevel 2 goto restcancel
)

echo.
echo =======================================
echo  RESTORE BACKUP
echo =======================================
tools\adb shell su -c "dd if=/sdcard/TA.img of=%partition%"

echo.
echo =======================================
echo  CLEAN UP
echo =======================================
del /q /s tmpbak\*.*
set imei=
set imeipartfound=
set imeibackupfound=
set origMD5=
set backupMD5sdcard=
set backupMD5=
tools\adb shell rm /sdcard/TA.img

echo.
echo *** Restore succesful! ***
goto restart

REM #####################
REM ## RESTORE FAILED
REM #####################
:restfail
echo.
echo =======================================
echo  CLEAN UP
echo =======================================
del /q /s tmpbak\*.*
set imei=
set imeipartfound=
set imeibackupfound=
set origMD5=
set backupMD5sdcard=
set backupMD5=
tools\adb shell rm /sdcard/TA.img

echo.
echo *** Restore was unsuccesful. ***
goto restart

REM #####################
REM ## RESTORE CANCELLED
REM #####################
:restcancel
echo.
echo =======================================
echo  CLEAN UP
echo =======================================
del /q /s tmpbak\*.*
set imei=
set imeipartfound=
set imeibackupfound=
set origMD5=
set backupMD5sdcard=
set backupMD5=
tools\adb shell rm /sdcard/TA.img

echo.
echo *** Restore was cancelled. ***
goto restart

REM #####################
REM ## CONVERT
REM #####################
:convert
echo.
echo =======================================
echo  INSTRUCTIONS
echo =======================================
echo  1. Make sure the image (backup file) is named TA.img
echo  2. Make a new file called TA.md5 and in this file save the MD5 hash of TA.img.
echo  3. ZIP both TA.img and TA.md5 in a ZIP file called TA-backup.zip
echo  4. Save this ZIP file in the 'Backup-TA\backup' folder.
echo.
goto restart

REM #####################
REM ## RESTART
REM #####################
:restart
REM # Pause for user interaction and then restart.
pause
goto main

REM #####################
REM ## QUIT
REM #####################
:quit
del /q tmpbak\*.*
rmdir tmpbak
tools\adb kill-server
set partition=