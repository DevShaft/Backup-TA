call:%*
goto:eof

REM #####################
REM ## MENU
REM #####################
:showMenu
cls
echo.
echo  [ ------------------------------------------------------------ ]
echo  [  Backup-TA v8.0 for Sony Xperia                              ]
echo  [ ------------------------------------------------------------ ]
echo  [  1. Backup                                                   ]
echo  [  2. Restore                                                  ]
echo  [  3. Convert v4 backup                                        ]
echo  [  4. Quit                                                     ]
echo  [ ------------------------------------------------------------ ]
choice /c:1234 /m "Please make your decision:"
set menuChoice=%errorlevel%
if %menuChoice% == 1 (
	call scripts/backup.bat backupTA
	set menuChoice=0
)
if %menuChoice% == 2 (
	call scripts/restore.bat restoreTA
	set menuChoice=0
)
if %menuChoice% == 3 (
	call scripts/convert.bat showConvertV4
	set menuChoice=0
)
if %menuChoice% == 4 (
	set menuChoice=-1
)

if %menuChoice%==0 (goto showMenu)
goto:eof

:dispose
set menuChoice=
goto:eof