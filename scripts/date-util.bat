call:%*
goto:eof

:getDateTime
setlocal enabledelayedexpansion
for /f "skip=1 tokens=2-4 delims=(-)" %%a in ('"echo.|date"') do (
    for /f "tokens=1-3 delims=/.- " %%A in ("%date:* =%") do (
        set %%a=%%A
        set %%b=%%B
        set %%c=%%C
    )
)

for /f "tokens=1-4 delims=:., " %%A in ("%time: =0%") do (
	set ts=%yy%%mm%%dd%.%%A%%B
	if NOT "%~1" == "" set %~1=%ts%
)
setlocal disabledelayedexpansion
goto:eof