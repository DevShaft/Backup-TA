call:%*
goto:eof

REM #####################
REM ## CONVERT
REM #####################
:convertRawTA
echo.
echo =======================================
echo  PROVIDE BACKUP
echo =======================================
if NOT exist convert-this mkdir convert-this > nul 2>&1
:copyTAFile
echo Copy your 'TA.img' file to the %CD%\convert-this\ folder.
echo.
%CHOICE% /c:yn %CHOICE_TEXT_PARAM% "Are you ready to continue?"
if "!errorlevel!" == "2" goto onConvertCancelled
if NOT exist convert-this\TA.img (
	echo.
	echo There is no 'TA.img' file found inside the 'convert-this' folder.
	goto copyTAFile
)
tools\md5.exe -l -n convert-this\TA.img>convert-this\TA.md5
echo.
echo =======================================
echo  PACKAGE BACKUP
echo =======================================
tools\adb.exe shell su -c "%BB% date +%%Y%%m%%d.%%H%%M%%S">tmpbak\convert_timestamp
set /p convert_timestamp=<tmpbak\convert_timestamp
cd convert-this
..\tools\zip.exe a ..\backup\TA-backup-!convert_timestamp!.zip TA.img TA.md5
if NOT "!errorlevel!" == "0" goto onConvertFailed
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
if "%~1" == "1" (
		echo *** Convert successful ***
		echo *** Your new backup is named '!filename!' ***
		echo *** It can be found at %CD%\backup ***
)
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
	)
)
goto:eof