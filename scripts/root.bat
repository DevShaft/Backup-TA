call:%*
goto:eof

REM #####################
REM ## ROOT CHECK
REM #####################
:check %~1
tools\adb shell ls /system/bin/su>tmpbak\su
set /p su=<tmpbak\su
if NOT "!su!" == "/system/bin/su" (
	tools\adb shell ls /system/xbin/su>tmpbak\su
	set /p su=<tmpbak\su
	if NOT "!su!" == "/system/xbin/su" (
		echo.
		echo *** Device is not properly rooted. ***
		goto:eof
	)
)
set %~1=1
set su=
del /q /s tmpbak\su > nul 2>&1
goto:eof