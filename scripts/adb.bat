call:%*
goto:eof

:wakeDevice
set /p "=Waiting for USB Debugging..." < nul
tools\adb.exe wait-for-device > nul
echo OK
goto:eof