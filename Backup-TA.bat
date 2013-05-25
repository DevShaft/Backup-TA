@echo off
set version=v8.5
if %PROCESSOR_ARCHITECTURE% == x86 (
	set choice=tools\choice32.exe
) else (
	set choice=tools\choice64.exe
)
cd %~dp0
call scripts\license.bat showLicense
call:initialize
call scripts\busybox.bat pushBusyBox
call scripts\menu.bat showMenu
goto quit

REM #####################
REM ## INITIALIZE
REM #####################
:initialize
cls
call scripts\adb.bat wakeDevice
set partition=/dev/block/mmcblk0p1
if NOT exist tmpbak mkdir tmpbak > nul 2>&1
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
