call:%*
goto:eof

REM #####################
REM ## PUSH BUSYBOX
REM #####################
:pushBusyBox
set /p "=Pushing BusyBox..." < nul
tools\adb push tools\busybox /data/local/tmp/busybox-backup-ta > nul 2>&1
tools\adb shell chmod 755 /data/local/tmp/busybox-backup-ta > nul 2>&1
set bb=/data/local/tmp/busybox-backup-ta
echo OK
goto:eof

REM #####################
REM ## REMOVE BUSYBOX
REM #####################
:removeBusyBox
set /p "=Removing BusyBox..." < nul
tools\adb shell rm /data/local/tmp/busybox-backup-ta > nul 2>&1
set bb=
echo OK
goto:eof

:dispose
call:removeBusyBox
goto:eof