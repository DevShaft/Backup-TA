call:%*
goto:eof

REM #####################
REM ## CONVERT
REM #####################
:showConvertV4
echo.
echo =======================================
echo  INSTRUCTIONS CONVERTING v4 BACKUP
echo =======================================
echo  1. Make sure the image (backup file) is named TA.img
echo  2. Make a new file called TA.md5 and in this file save the MD5 hash of TA.img.
echo  3. ZIP both TA.img and TA.md5 in a ZIP file called TA-backup.zip
echo  4. Save this ZIP file in the 'Backup-TA\backup' folder.
echo.
pause
call:exit
goto:eof

:convertV4
echo.
echo =======================================
echo  PROVIDE BACKUP
echo =======================================
if NOT exist convert-this mkdir convert-this > nul 2>&1
:copyTAFile
echo Copy your 'TA.img' file to the %CD%\convert-this\ folder.
echo.
%CHOICE% /c:yn %CHOICE_TEXT_PARAM% "Are you ready to continue?"
if errorlevel 2 goto onConvertCancelled
if NOT exist convert-this\TA.img (
	echo.
	echo There is no 'TA.img' file found inside the 'convert-this' folder.
	goto copyTAFile
)
tools\md5 -l -n convert-this\TA.img>convert-this\TA.md5
echo.
echo =======================================
echo  PACKAGE BACKUP
echo =======================================
tools\adb shell su -c "%BB% date +%%Y%%m%%d.%%H%%M%%S">tmpbak\convert_timestamp
set /p convert_timestamp=<tmpbak\convert_timestamp
cd convert-this
..\tools\zip a ..\backup\TA-backup-!convert_timestamp!.zip TA.img TA.md5
if NOT "%errorlevel%" == "0" goto onConvertFailed
cd..
call:exit 1
goto:eof

REM #####################
REM ## CONVERT CANCELLED
REM #####################
:onConvertCancelled
call:exit 2
goto:eof

REM #####################
REM ## CONVERT FAILED
REM #####################
:onConvertFailed
call:exit 3
goto:eof

REM #####################
REM ## EXIT CONVERT
REM #####################
:exit
set filename=TA-backup-!convert_timestamp!.zip
call:dispose %~1
echo.
if "%~1" == "1" echo *** Convert successful ***
if "%~1" == "1" echo *** Your new backup is named '!filename!' ***
if "%~1" == "1" echo *** It can be found at %CD%\backup ***
if "%~1" == "2" echo *** Convert cancelled. ***
if "%~1" == "3" echo *** Convert unsuccessful. ***
set filename=
echo.
pause
goto:eof

REM #####################
REM ## DISPOSE CONVERT
REM #####################
:dispose
set convert_timestamp=
if "%~1" == "1" (
	del /q /s tmpbak\convert_*.* > nul 2>&1
	
	if exist convert-this (
		del /q /s convert-this\*.*
		rmdir convert-this
	)
)
goto:eof