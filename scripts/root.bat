call:%*
goto:eof

REM #####################
REM ## ROOT CHECK
REM #####################
:check
set /p "=Checking for SU binary..." < nul
tools\adb shell %BB% ls /system/bin/su>tmpbak\su
set /p su=<tmpbak\su
if NOT "!su!" == "[1;32m/system/bin/su[0m" (
	tools\adb shell %BB% ls /system/xbin/su>tmpbak\su
	set /p su=<tmpbak\su
	if NOT "!su!" == "[1;32m/system/xbin/su[0m" (
		echo FAILED
	) else (
		echo OK
	)
)
set /p "=Requesting root permissions..." < nul
tools\adb shell su -c "%BB% echo true">tmpbak\rootPermission
set /p rootPermission=<tmpbak\rootPermission
if NOT "!rootPermission!" == "true" (
	echo FAILED
	goto:eof
)
echo OK
set %~1=1
set su=
del /q /s tmpbak\su > nul 2>&1
del /q /s tmpbak\rootPermission > nul 2>&1
goto:eof