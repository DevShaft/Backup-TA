call:%*
goto:eof

:strlen <resultVar> <stringVar>
(   
    set s=!%~2!#
    set len=0
    for %%P in (4096 2048 1024 512 256 128 64 32 16 8 4 2 1) do (
        if NOT "!s:~%%P,1!" == "" ( 
            set /a len+=%%P
            set s=!s:~%%P!
        )
    )
    
    set %~1=!len!
    goto:eof
)