#####################
## ROOT CHECK
#####################
function hasRoot {
  echo -n "Checking for SU binary..."
  if [ "`. $ADB_SHELL check_su_binary`" == "" ]; then
    echo "FAILED"
    exit
  else
    echo "OK"
  fi;

  echo -n "Requesting root permissions..."
  if [[ "`. $ADB_ROOT_SHELL request_root`" == *true* ]]; then
    echo "OK"
  else
    echo "FAILED"
    exit
  fi;
}
