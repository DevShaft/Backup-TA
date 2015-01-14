#####################
## BACKUP
#####################
function inspectPartition() {
  part=$1
  echo " --- $part --- "
  echo -n "Searching for Operator Identifier... "
  if [[ "`. $ADB_ROOT_SHELL search_operator_id $part`" == *1* ]]; then
    echo "+"
    echo -n "Searching for Operator Name... "
    if [[ "`. $ADB_ROOT_SHELL search_operator_name $part`" == *1* ]]; then
      echo "+"
      echo -n "Searching for Rooting Status... "
      if [[ "`. $ADB_ROOT_SHELL search_rooting_allowed $part`" == *1* ]]; then
        echo "+"
        echo -n "Searching for S1 Boot... "
        if [[ "`. $ADB_ROOT_SHELL search_s1_boot $part`" == *1* ]]; then
          echo "+"
          echo -n "Searching for S1 Loader... "
          if [[ "`. $ADB_ROOT_SHELL search_s1_loader $part`" == *1* ]]; then
            echo "+"
            echo -n "Searching for S1 Hardware Configuration... "
            if [[ "`. $ADB_ROOT_SHELL search_s1_hwconf $part`" == *1* ]]; then
              echo "+"
              return 0
            fi
          fi
        fi
      fi
    fi
  fi
  echo "-"
  return 1
}

function backupTA {
  echo
  [ ! -d backup ] && mkdir backup > /dev/null 2>&1
  wakeDevice
  echo
  echo "======================================="
  echo " FIND TA PARTITION"
  echo "======================================="
  partition=`. $ADB_ROOT_SHELL readlink $PARTITION_BY_NAME`
  if [ "`$ADB shell su -c \"[ -b '$partition' ] && echo -n 1\"`" == "1" ]; then
    echo "Partition found!"
  else
    echo "Partition not found by name."
    echo
    read -n1 -s -p "Do you want to perform an extensive search for the TA? Y/n" CHOICE
    case $CHOICE in
      [Nn]) onBackupCancelled ;;
    esac

    echo
    echo "======================================="
    echo " INSPECTING PARTITIONS"
    echo "======================================="
    backup_taPartitionName=
    while read partition; do
      partition=$(echo "$partition" | tr -dc "[:alnum:]") 
      inspectPartition $partition
      if [ "$?" == "0" ]; then
        if [ "$backup_taPartitionName" == "" ]; then
          backup_taPartitionName="/dev/block/$partition"
          echo "Partition found^^!"
        else
          echo "*** More than one partition match the TA partition search criteria. ***"
          echo "*** Therefore it is not possible to determine which one or ones to use. ***"
          echo "*** Contact DevShaft @XDA-forums for support. ***"
          onBackupCancelled
        fi
      fi
    done < <(. $ADB_ROOT_SHELL list_partitions)

    if [ "$backup_taPartitionName" == "" ]; then
      echo "*** No compatible TA partition found on your device. ***"
      onBackupCancelled
    fi
    partition=$backup_taPartitionName
  fi

  echo
  echo "======================================="
  echo " BACKUP TA PARTITION"
  echo "======================================="
  echo "Partition: $partition"
  realSdCard=$($ADB shell su -c "$BB readlink -n /sdcard1")
  currentPartitionMD5=$($ADB shell su -c "$BB md5sum $partition | $BB awk {'printf \\\$1'}")
  $ADB shell su -c "$BB dd if=$partition of=$realSdCard/backupTA.img"

  echo
  echo "======================================="
  echo " INTEGRITY CHECK"
  echo "======================================="
  backupMD5=$($ADB shell su -c "$BB md5sum $realSdCard/backupTA.img | $BB awk {'printf \\\$1'}")
  echo -n "Backup checksum matches partition checksum... "
  if [ "$currentPartitionMD5" != "$backupMD5" ]; then
    echo "FAILED"
    onBackupFailed
  else
    echo "OK"
  fi

  echo
  echo "======================================="
  echo " PULL BACKUP FROM SDCARD"
  echo "======================================="
  $ADB pull $realSdCard/backupTA.img tmpbak/TA.img || onBackupFailed

  echo
  echo "======================================="
  echo " INTEGRITY CHECK"
  echo "======================================="
  backupPulledMD5=$(md5sum tmpbak/TA.img | awk {'printf $1'})
  echo -n "Local backup checksum matches partition checksum... "
  if [ "$currentPartitionMD5" != "$backupPulledMD5" ]; then
    echo "FAILED"
    onBackupFailed
  else
    echo "OK"
  fi

  echo
  echo "======================================="
  echo " PACKAGE BACKUP"
  echo "======================================="
  $ADB get-serialno > tmpbak/TA.serial
  echo $partition > tmpbak/TA.blk
  echo $backupPulledMD5 > tmpbak/TA.md5
  echo $VERSION > tmpbak/TA.version
  timestamp=$($ADB shell su -c \"$BB date +%Y%m%d.%H%M%S\")
  echo $timestamp > tmpbak/TA.timestamp
  cd tmpbak
  zip ../backup/TA-backup-$timestamp.zip TA.img TA.md5 TA.blk TA.serial TA.timestamp TA.version || onBackupFailed
  cd ..
  exit_backup 1
}

#####################
## BACKUP CANCELLED
######################
function onBackupCancelled {
   exit_backup 2
}

#####################
## BACKUP FAILED
#####################
function onBackupFailed {
  exit_backup 3
}

#####################
## EXIT BACKUP
#####################
function exit_backup () {
  dispose $1
  echo
  case $1 in
    "1") echo "*** Backup successful. ***" ;;
    "2") echo "*** Backup cancelled. ***" ;;
    "3") echo "*** Backup failed. ***" ;;
  esac
  echo
  read -n1 -s
  exit $1
}

#####################
## DISPOSE BACKUP
#####################
function backup_dispose {
  if [ "$1" == "1" ]; then
    rm -rf tmpbak/backup_*.* > /dev/null 2>&1
    rm -rf tmpbak\TA.* > /dev/null 2>&1
  fi
  $ADB shell rm /sdcard/backupTA.img > /dev/null 2>&1
}
