@echo off
setlocal EnableDelayedExpansion

set VERSION=v9.6
if exist "%PROGRAMFILES(X86)%" (
	set CHOICE=tools\choice64.exe
	set CHOICE_TEXT_PARAM=/m
) else (
	if %PROCESSOR_ARCHITECTURE% == x86 (
		set CHOICE=tools\choice32.exe
		set CHOICE_TEXT_PARAM=
	) else (
		set CHOICE=tools\choice64.exe
		set CHOICE_TEXT_PARAM=/m
	)
)
cd %~dp0
if NOT exist tmpbak mkdir tmpbak > nul 2>&1
call scripts\license.bat showLicense
call:initialize
call scripts\busybox.bat pushBusyBox
call scripts\root.bat check hasRoot
if NOT "!hasRoot!" == "1" goto quit
call scripts\menu.bat showMenu
goto quit

REM #####################
REM ## INITIALIZE
REM #####################
:initialize
cls
call scripts\adb.bat wakeDevice
set PARTITION_BY_NAME=/dev/block/platform/msm_sdcc.1/by-name/TA
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
call scripts\convert.bat dispose

if exist tmpbak (
	del /q /s tmpbak\*.*
	rmdir tmpbak
)

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
echo.
pause
goto:eof
