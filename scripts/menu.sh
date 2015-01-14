#####################
## MENU
#####################
function showMenu {
  while true; do
    menu=('Backup' 'Restore' 'Restore dry-run' 'Convert TA.img' 'Quit')
    menu_currentIndex=1
    menu_choices=1
    clear
    echo
    echo  "[ ------------------------------------------------------------ ]"
    echo  "[  Backup TA v$VERSION for Sony Xperia                             ]"
    echo  "[ ------------------------------------------------------------ ]"
    for el in "${menu[@]}"; do
      echo  ">  $menu_currentIndex.$el                                                   "
      let menu_currentIndex=menu_currentIndex+1
    done;
    echo  "[ ------------------------------------------------------------ ]"

    #%CHOICE% /c:!menu_choices! %CHOICE_TEXT_PARAM% "Please make your decision:"
    read -n1 -s CHOICE
    case $CHOICE in
      "1") menu_1 && exit ;;
      "2") menu_2 && exit ;;
      "3") menu_3 && exit ;;
      "4") menu_4 && exit ;;
      "5") menu_5 && exit ;;
    esac
  done
}

function menu_1 {
  clear
  echo
  echo =======================================
  echo  BACKUP
  echo =======================================
  echo When you continue Backup TA will perform a backup of the TA partition.
  echo First it will look for the TA partition by its name. When it can not
  echo be found this way it will ask you to perform an extensive search.
  echo The extensive search will inspect many of the partitions on your device,
  echo in the hope to find it and continue with the backup process.
  echo
  echo "Do you want to continue? y/N"

  while true; do
    read -n1 -s CHOICE
    case $CHOICE in
      [Yy])
        backupTA
      ;;
      *)
        break
      ;;
    esac
  done
}

function menu_2 {
  clear
  echo
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
  echo
  echo "Do you want to continue? y/N"

  while true; do
    read -n1 -s CHOICE
    case $CHOICE in
      [Yy])
        restoreTA
      ;;
      *)
        break
      ;;
    esac
  done
}

function menu_3 {
  clear
  echo
  echo =======================================
  echo  RESTORE DRY-RUN
  echo =======================================
  echo When you continue Backup TA will perform the restore of a TA partition
  echo in 'dry-run' mode. This mode performs the restore just like the regular
  echo restore with the exception that it will not do an actual restore of the 
  echo backup to the device. It will however perform every integrity check, so 
  echo you can test beforehand if your backup is invalid or corrupted.
  echo
  echo "Do you want to continue? y/N"

  while true; do
    read -n1 -s CHOICE
    case $CHOICE in
      [Yy])
        restoreTAdry
      ;;
      *)
        break
      ;;
    esac
  done
}

function menu_4 {
  clear
  echo
  echo =======================================
  echo  CONVERT TA.IMG
  echo =======================================
  echo When you continue Backup TA will ask you to copy your TA.img file to a location
  echo and then convert this backup to make it compatible with the latest version
  echo of Backup TA.
  echo
  echo "Do you want to continue? y/N"

  while true; do
    read -n1 -s CHOICE
    case $CHOICE in
      [Yy])
        convertRawTA
      ;;
      *)
        break
      ;;
    esac
  done
}

function menu_5 {
  return 0
}
