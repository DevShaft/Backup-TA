call:%*
goto:eof

REM #####################
REM ## PUSH BUSYBOX
REM #####################
:pushBusyBox
set /p "=Pushing Backup TA Tools..." < nul
tools\adb.exe push tools\busybox /data/local/tmp/busybox-backup-ta > nul 2>&1
tools\adb.exe shell chmod 755 /data/local/tmp/busybox-backup-ta > nul 2>&1
set BB=/data/local/tmp/busybox-backup-ta
echo OK
goto:eof

REM #####################
REM ## REMOVE BUSYBOX
REM #####################
:removeBusyBox
set /p "=Removing Backup TA Tools..." < nul
tools\adb.exe shell rm /data/local/tmp/busybox-backup-ta > nul 2>&1
set bb=
echo OK
goto:eof

:dispose
call:removeBusyBox
goto:eof