#####################
## PUSH BUSYBOX
#####################
function pushBusyBox {
  echo -n "Pushing Backup TA Tools... "
  $ADB push tools/busybox $BB > /dev/null 2>&1
  $ADB shell chmod 755 $BB > /dev/null 2>&1
  echo "OK"
}

#####################
## REMOVE BUSYBOX
#####################
function removeBusyBox {
  echo -n "Removing Backup TA Tools... "
  $ADB shell rm $BB > /dev/null 2>&1
  echo "OK"
}

function busybox_dispose {
  removeBusyBox
}
