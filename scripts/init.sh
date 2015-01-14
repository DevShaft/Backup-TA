#!/bin/bash
#####################
## INITIALIZE
#####################
function initialize {
  clear
  echo
  echo  "[ ———––––----------------------------------------------––––——— ]"
  echo  "[  Backup TA v$VERSION for Sony Xperia                             ]"
  echo  "[ ———––––----------------------------------------------––––——— ]"
  echo  "[  Initialization                                              ]"
  echo  "[                                                              ]"
  echo  "[  Make sure that you have USB Debugging enabled, you do       ]"
  echo  "[  allow your computer ADB access by accepting its RSA key     ]"
  echo  "[  (only needed for Android 4.2.2 or higher) and grant this    ]"
  echo  "[  ADB process root permissions through superuser.             ]"
  echo  "[ ———––––----------------------------------------------––––——— ]"
  echo
  PARTITION_BY_NAME="/dev/block/platform/msm_sdcc.1/by-name/TA"
  BB="/data/local/tmp/busybox-backup-ta"
  ADB="tools/adb.linux"
  SCRIPTS="./scripts"
  ANDROID="$SCRIPTS/android"
  ADB_SHELL="$ANDROID/adb_shell.linux"
  ADB_ROOT_SHELL="$ANDROID/adb_root_shell.linux"
}

#####################
## DISPOSE
#####################
function dispose {
  echo
  echo "======================================="
  echo " CLEAN UP"
  echo "======================================="
  partition=
  choiceTextParam=
  choice=

  backup_dispose
  restore_dispose
  convert_dispose

  [ -d "tmpbak" ] && rm -rf tmpbak

  busybox_dispose

  echo "=Killing ADB Daemon..."
  $ADB kill-server > nul 2>&1

  echo "OK"
}

#####################
## QUIT
#####################
function quit {
  dispose
  echo
  read -p "Press any key to exit" -n1 -s
}
