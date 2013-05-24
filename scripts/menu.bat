call:%*
goto:eof

REM #####################
REM ## MENU
REM #####################
:showMenu
set menu_currentIndex=1
set menu_choices=1
cls
echo.
echo  [ ------------------------------------------------------------ ]
echo  [  Backup-TA %version% for Sony Xperia                              ]
echo  [ ------------------------------------------------------------ ]
echo  [  %menu_currentIndex%. Backup                                                   ]

set /a menu_currentIndex+=1 >nul
set menu_choices=%menu_choices%%menu_currentIndex%

echo  [  %menu_currentIndex%. Restore                                                  ]

set /a menu_currentIndex+=1 >nul
set menu_choices=%menu_choices%%menu_currentIndex%

echo  [  %menu_currentIndex%. Restore dry-run                                          ]

set /a menu_currentIndex+=1 >nul
set menu_choices=%menu_choices%%menu_currentIndex%

echo  [  %menu_currentIndex%. Convert v4 backup                                        ]

set /a menu_currentIndex+=1 >nul
set menu_choices=%menu_choices%%menu_currentIndex%

echo  [  %menu_currentIndex%. Quit                                                     ]
echo  [ ------------------------------------------------------------ ]

tools\choice.exe /c:%menu_choices% /m "Please make your decision:"

set menu_decision=%errorlevel%
set menu_currentIndex=
set menu_choices=

if %menu_decision% == 1 (
	call scripts\backup.bat backupTA
	set menu_decision=0
)
if %menu_decision% == 2 (
	call scripts\restore.bat restoreTA
	set menu_decision=0
)
if %menu_decision% == 3 (
	call scripts\restore.bat restoreTAdry
	set menu_decision=0
)
if %menu_decision% == 4 (
	call scripts\convert.bat showConvertV4
	set menu_decision=0
)
if %menu_decision% == 5 (
	set menu_decision=-1
)

if %menu_decision%==0 (goto showMenu)
goto:eof

:dispose
set menu_decision=
set menu_currentIndex=
set menu_choices=
goto:eof