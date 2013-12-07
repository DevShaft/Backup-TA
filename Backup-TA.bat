@echo off
setlocal EnableDelayedExpansion
set VERSION=9.9

REM #####################
REM ## CHOICE CHECK
REM #####################
choice /T 0 /D Y /C Y /M test > nul 2>&1
if "!errorlevel!" == "1" (
	set CHOICE=choice
	set CHOICE_TEXT_PARAM=/M
) else (
	choice /T 0 /D Y /C Y test > nul 2>&1
	if "!errorlevel!" == "1" (
		set CHOICE=choice
		set CHOICE_TEXT_PARAM=
	) else (
		tools\choice64.exe /T 0 /D Y /C Y /M test > nul 2>&1
		if "!errorlevel!" == "1" (
			set CHOICE=tools\choice64.exe
			set CHOICE_TEXT_PARAM=/M
		) else (
			tools\choice32.exe /TY,1 /CY > nul 2>&1
			if "!errorlevel!" == "1" (
				set CHOICE=tools\choice32.exe
			) else (
				tools\choice32_alt.exe /T 0 /D Y /C Y /M test > nul 2>&1
				if "!errorlevel!" == "1" (
					set CHOICE=tools\choice32_2.exe
					set CHOICE_TEXT_PARAM=/M
				)
			)
		)
	)
)

cd %~dp0
if NOT exist tmpbak mkdir tmpbak > nul 2>&1
call scripts\license.bat showLicense
call:initialize
call scripts\adb.bat wakeDevice
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
echo.
echo  [ ------------------------------------------------------------ ]
echo  [  Backup TA v%VERSION% for Sony Xperia                              ]
echo  [ ------------------------------------------------------------ ]
echo  [  Initialization                                              ]
echo  [                                                              ]
echo  [  Make sure that you have USB Debugging enabled, you do       ]
echo  [  allow your computer ADB access by accepting its RSA key     ]
echo  [  (only needed for Android 4.2.2 or higher) and grant this    ]
echo  [  ADB process root permissions through superuser.             ]
echo  [ ------------------------------------------------------------ ]
echo.
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
