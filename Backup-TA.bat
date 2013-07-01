@echo off
setlocal EnableDelayedExpansion

set VERSION=v9.1b1
if %PROCESSOR_ARCHITECTURE% == x86 (
	set CHOICE=tools\choice32.exe
	set CHOICE_TEXT_PARAM=
) else (
	set CHOICE=tools\choice64.exe
	set CHOICE_TEXT_PARAM=/m
)
cd %~dp0
call scripts\license.bat showLicense
call:initialize
call scripts\busybox.bat pushBusyBox
if NOT exist tmpbak mkdir tmpbak > nul 2>&1

tools\adb shell ls /system/bin/su>tmpbak\hasRoot
set /p hasRoot=<tmpbak\hasRoot
if NOT "!hasRoot!" == "/system/bin/su" (
	tools\adb shell ls /system/xbin/su>tmpbak\hasRoot
	set /p hasRoot=<tmpbak\hasRoot
	if NOT "!hasRoot!" == "/system/xbin/su" (
		echo.
		echo *** Device is not properly rooted. ***
		goto quit
	)
)
set hasRoot=
del /q /s tmpbak\hasRoot

call scripts\menu.bat showMenu
goto quit

REM #####################
REM ## INITIALIZE
REM #####################
:initialize
cls
call scripts\adb.bat wakeDevice
set partitionByName=/dev/block/platform/msm_sdcc.1/by-name/TA
goto:eof

REM #####################
REM ## DISPOSE
REM #####################
:dispose
echo.
echo =======================================
echo  CLEAN UP
echo =======================================
set partition=
set choiceTextParam=
set choice=

call scripts\menu.bat dispose
call scripts\backup.bat dispose
call scripts\restore.bat dispose

del /q /s tmpbak\*.*
if exist tmpbak rmdir tmpbak

call scripts\busybox.bat dispose

set /p "=Killing ADB Daemon..." < nul
tools\adb kill-server > nul 2>&1
echo OK
goto:eof

REM #####################
REM ## QUIT
REM #####################
:quit
call:dispose
goto:eof
