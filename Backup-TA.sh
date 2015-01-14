#!/bin/bash
VERSION="9.11"
path=`dirname $0`

for i in scripts/*.sh ; do
    if [ -r "$i" ]; then
        . $i
    fi
done

cd $path
[ ! -d "tmpbak" ] && mkdir tmpbak > /dev/null  2>&1
showLicense

initialize
wakeDevice
pushBusyBox
hasRoot
showMenu
quit
