call:%*
goto:eof

REM #####################
REM ## CONVERT
REM #####################
:showConvertV4
echo.
echo =======================================
echo  INSTRUCTIONS CONVERTING v4 BACKUP
echo =======================================
echo  1. Make sure the image (backup file) is named TA.img
echo  2. Make a new file called TA.md5 and in this file save the MD5 hash of TA.img.
echo  3. ZIP both TA.img and TA.md5 in a ZIP file called TA-backup.zip
echo  4. Save this ZIP file in the 'Backup-TA\backup' folder.
echo.
pause
call:exit
goto:eof

REM #####################
REM ## EXIT CONVERT
REM #####################
:exit
goto:eof
