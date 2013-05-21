call:%*
goto:eof

:strlen <resultVar> <stringVar>
(   
    setlocal enabledelayedexpansion
    set "s=!%~2!#"
    set "len=0"
    for %%P in (4096 2048 1024 512 256 128 64 32 16 8 4 2 1) do (
        if "!s:~%%P,1!" NEQ "" ( 
            set /a "len+=%%P"
            set "s=!s:~%%P!"
        )
    )
    
    goto strlenReturn
)

:strlenReturn
( 
    endlocal
    set "%~1=%len%"
    exit /b
)