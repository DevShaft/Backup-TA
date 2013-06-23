call:%*
goto:eof

REM #####################
REM ## FIND
REM #####################
:findTA
echo.
set find_taPartitionName=
tools\adb get-serialno>tmpbak\find_serialno
set /p find_serialno=<tmpbak\find_serialno

echo.
echo =======================================
echo  INSPECTING PARTITIONS
echo =======================================


tools\adb shell su -c "%bb% cat /proc/partitions | %bb% grep -o ' [0-9]\{1,4\} mmc.*' | %bb% grep -o 'mmc.*'">tmpbak\find_potentialPartitions
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
echo --- %1 ---
set /p "=Searching for Serial No..." < nul
tools\adb shell su -c "%bb% cat /dev/block/%1 | %bb% grep -s -m 1 -c '%find_serialno%'">tmpbak\find_matchSerial
set /p find_matchSerial=<tmpbak\find_matchSerial
if "%find_matchSerial%" == "1" (
	echo +
) else (
	echo -
)
set /p "=Searching for Marlin Certificate..." < nul
tools\adb shell su -c "%bb% cat /dev/block/%1 | %bb% grep -s -m 1 -c -i 'marlin:datacertification'">tmpbak\find_matchMarlin
set /p find_matchMarlin=<tmpbak\find_matchMarlin
if "%find_matchMarlin%" == "1" (
	echo +
) else (
	echo -
)

if "%find_matchSerial%" == "1" (
	if "%find_matchMarlin%" == "1" (
		if "%find_taPartitionName%" == "" (
			set find_taPartitionName=%1
		) else (
			echo.
			goto onFindMultiple
		)
	)
)
echo.
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
REM ## FIND MULTIPLE
REM #####################
:onFindMultiple
call:exit 5
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
if "%~1" == "1" echo *** Your device appears to be compatible. ***
if "%~1" == "2" echo *** Operation cancelled. ***
if "%~1" == "3" (
	echo *** The TA partition on your device appears to be located at %find_taPartitionNameLocal%. *** 
	echo *** This is a different location than the location compatible for this tool. ***
	echo *** Contact DevShaft @XDA-forums for support. *** 
)
if "%~1" == "4" echo *** No compatible TA partition found on your device. ***
if "%~1" == "5" (
	echo *** More than one partition match the TA partition search criteria. ***
	echo *** Therefore it is not possible to determine which one or ones to use. ***
	echo *** Contact DevShaft @XDA-forums for support. *** 
)
echo.
set find_taPartitionNameLocal=
pause
goto:eof

REM #####################
REM ## DISPOSE FIND
REM #####################
:dispose
set find_taPartitionName=
set find_matchSerial=
set find_serialno=
set find_matchMarlin=
goto:eof