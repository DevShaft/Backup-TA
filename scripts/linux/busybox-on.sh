#!/bin/bash 

adb push ../../tools/busybox /data/local/tmp/busybox-backup-ta 
adb shell chmod 755 /data/local/tmp/busybox-backup-ta 