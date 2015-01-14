function wakeDevice {
  echo -n "Waiting for USB Debugging... "
  $ADB wait-for-device > /dev/null
  echo "OK"
}