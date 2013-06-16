call:%*
goto:eof

REM #####################
REM ## FIND
REM #####################
:findTA
echo.
set find_taPartitionName=
set find_inputIMEI=
set /p find_inputIMEI=Enter your IMEI (digits only): 
set find_inputIMEILen=
call scripts\string-util.bat strlen find_inputIMEILen find_inputIMEI
if NOT "%find_inputIMEILen%" == "15" goto onFindInvalidIMEI
set find_inputIMEILen=
setlocal enabledelayedexpansion
set find_inputIMEI=!find_inputIMEI:~0,-1!
setlocal disabledelayedexpansion
verify > nul
set find_inputSerial=
set /p find_inputSerial=Enter your serial: 
verify > nul

echo.
echo =======================================
echo  INSPECTING PARTITIONS
echo =======================================
tools\adb shell su -c "cat /proc/partitions | grep -o '\b[0-9]\{1,4\} mmc.*' | grep -o 'mmc.*'">tmpbak\find_potentialPartitions
for /F "tokens=*" %%A in (tmpbak\find_potentialPartitions) do call:inspectPartition %%A
if "%find_taPartitionName%" == "mmcblk0p1" (
	goto onFindSuccess
) else if NOT "%find_taPartitionName%" == "" (
	goto onFindHope
) else (
	goto onFindUnknown
)
echo.
pause
goto:eof

:inspectPartition
set /p "=Inspecting %1..." < nul
tools\adb shell su -c "cat /dev/block/%1 | grep -s -m 1 -c '%find_inputIMEI%'">tmpbak\find_matchIMEI
set /p find_matchIMEI=<tmpbak\find_matchIMEI
tools\adb shell su -c "cat /dev/block/%1 | grep -s -m 1 -c '%find_inputSerial%'">tmpbak\find_matchSerial
set /p find_matchSerial=<tmpbak\find_matchSerial
tools\adb shell su -c "cat /dev/block/%1 | grep -s -m 1 -c -i 'marlin:datacertification'">tmpbak\find_matchMarlin
set /p find_matchMarlin=<tmpbak\find_matchMarlin

set partitionDoesMatch=0

if "%find_matchIMEI%" == "1" (
	if "%find_matchSerial%" == "1" (
		if "%find_matchMarlin%" == "1" (
			if "%find_taPartitionName%" == "" (
				set find_taPartitionName=%1
			) else (
				echo.
				goto onFindUnknown
			)
			set partitionDoesMatch=1
		)
	)
)
echo done
goto:eof

REM #####################
REM ## FIND INVALID IMEI
REM #####################
:onFindInvalidIMEI
echo Invalid IMEI provided.
goto onFindCancelled
goto:eof

REM #####################
REM ## FIND SUCCESS
REM #####################
:onFindSuccess
call:exit 1
goto:eof

REM #####################
REM ## FIND HOPE
REM #####################
:onFindHope
call:exit 3
goto:eof

REM #####################
REM ## FIND UNKNOWN
REM #####################
:onFindUnknown
call:exit 4
goto:eof

REM #####################
REM ## FIND CANCELLED
REM #####################
:onFindCancelled
call:exit 2
goto:eof

REM #####################
REM ## EXIT FIND
REM #####################
:exit
set find_taPartitionNameLocal=%find_taPartitionName%
call:dispose
echo.
if "%~1" == "1" echo *** Your device appears to be compatible. ***
if "%~1" == "2" echo *** Operation cancelled. ***
if "%~1" == "3" (
	echo *** The TA partition of your device appears to be %find_taPartitionNameLocal%. *** 
	echo *** This is a different partition than the one compatible with this tool. ***
	echo *** Contact DevShaft @XDA-forums for the possibility to make the tool compatible. *** 
)
if "%~1" == "4" echo *** The TA partition for your device can not be determined. ***
echo.
set find_taPartitionNameLocal=
pause
goto:eof

REM #####################
REM ## DISPOSE FIND
REM #####################
:dispose
set find_taPartitionName=
set find_inputIMEI=
set find_matchSerial=
set find_inputIMEILen=
set find_inputSerial=
set find_matchIMEI=
set find_matchMarlin=
goto:eof