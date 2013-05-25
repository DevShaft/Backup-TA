call:%*
goto:eof

:wakeDevice
set /p "=Waiting for device..." < nul
tools\adb wait-for-device > nul
echo OK
goto:eof