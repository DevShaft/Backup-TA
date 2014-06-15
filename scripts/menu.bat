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
echo  [  Backup TA v%VERSION% for Sony Xperia                             ]
echo  [ ------------------------------------------------------------ ]
echo  [  !menu_currentIndex!. Backup                                                   ]

set /a menu_currentIndex+=1 >nul
set menu_choices=!menu_choices!!menu_currentIndex!

echo  [  !menu_currentIndex!. Restore                                                  ]

set /a menu_currentIndex+=1 >nul
set menu_choices=!menu_choices!!menu_currentIndex!

echo  [  !menu_currentIndex!. Restore dry-run                                          ]

set /a menu_currentIndex+=1 >nul
set menu_choices=!menu_choices!!menu_currentIndex!

echo  [  !menu_currentIndex!. Convert TA.img                                           ]

set /a menu_currentIndex+=1 >nul
set menu_choices=!menu_choices!!menu_currentIndex!

echo  [  !menu_currentIndex!. Quit                                                     ]
echo  [ ------------------------------------------------------------ ]

%CHOICE% /c:!menu_choices! %CHOICE_TEXT_PARAM% "Please make your decision:"

set menu_decision=!errorlevel!
set menu_currentIndex=
set menu_choices=

if "!menu_decision!" == "1" (
	echo.
	echo =======================================
	echo  BACKUP
	echo =======================================
	echo When you continue Backup TA will perform a backup of the TA partition.
	echo First it will look for the TA partition by its name. When it can not
	echo be found this way it will ask you to perform an extensive search.
	echo The extensive search will inspect many of the partitions on your device,
	echo in the hope to find it and continue with the backup process.
	echo.
	%CHOICE% /c:yn %CHOICE_TEXT_PARAM% "Are you sure you want to continue?"
	if "!errorlevel!" == "2" goto showMenu
	call scripts\backup.bat backupTA
	set menu_decision=0
) 
if "!menu_decision!" == "2" (
	echo.
	echo =======================================
	echo  RESTORE
	echo =======================================
	echo When you continue Backup TA will perform a restore of a TA partition
	echo backup. There will be many integrity checks along the way to make sure
	echo a restore will either complete successfully, revert when something goes
	echo wrong while restoring or fail before the restore begins because of an
	echo invalid backup. There is always a risk when writing to an important
	echo partition like TA, but with these safeguards that risk is kept to an
	echo absolute minimum. 
	echo.
	%CHOICE% /c:yn %CHOICE_TEXT_PARAM% "Are you sure you want to continue?"
	if "!errorlevel!" == "2" goto showMenu
	call scripts\restore.bat restoreTA
	set menu_decision=0
)
if "!menu_decision!" == "3" (
	echo.
	echo =======================================
	echo  RESTORE DRY-RUN
	echo =======================================
	echo When you continue Backup TA will perform the restore of a TA partition
	echo in 'dry-run' mode. This mode performs the restore just like the regular
	echo restore with the exception that it will not do an actual restore of the 
	echo backup to the device. It will however perform every integrity check, so 
	echo you can test beforehand if your backup is invalid or corrupted.
	echo.
	%CHOICE% /c:yn %CHOICE_TEXT_PARAM% "Are you sure you want to continue?"
	if "!errorlevel!" == "2" goto showMenu
	call scripts\restore.bat restoreTAdry
	set menu_decision=0
)
if "!menu_decision!" == "4" (
	echo.
	echo =======================================
	echo  CONVERT TA.IMG
	echo =======================================
	echo When you continue Backup TA will ask you to copy your TA.img file to a location
	echo and then convert this backup to make it compatible with the latest version
	echo of Backup TA.
	echo.
	%CHOICE% /c:yn %CHOICE_TEXT_PARAM% "Are you sure you want to continue?"
	if "!errorlevel!" == "2" goto showMenu
	call scripts\convert.bat convertRawTA
	set menu_decision=0
)
if "!menu_decision!" == "5" (
	set menu_decision=-1
)

if "!menu_decision!" == "0" goto showMenu
goto:eof

:dispose
set menu_decision=
set menu_currentIndex=
set menu_choices=
goto:eof
