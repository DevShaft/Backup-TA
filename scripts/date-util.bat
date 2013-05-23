call:%*
goto:eof

:getDateTime
for /f "skip=1 tokens=2-4 delims=(-)" %%a in ('"echo.|date"') do (
    for /f "tokens=1-3 delims=/.- " %%A in ("%date:* =%") do (
        set %%a=%%A
        set %%b=%%B
        set %%c=%%C
    )
)

for /f "tokens=1-4 delims=:., " %%A in ("%time: =0%") do (
	set /a "yy=10000%yy% %%10000,mm=100%mm% %% 100,dd=100%dd% %% 100"
	set ts=%yy%%mm%%dd%.%%A%%B
)
if NOT "%~1" == "" set %~1=%ts%
goto:eof