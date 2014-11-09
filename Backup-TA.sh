#!/bin/bash 

VERSION=9.11

echo "[ ------------------------------------------------------------ ]"
echo "[  Backup TA v$VERSION for Sony Xperia                             ]"
echo "[ ------------------------------------------------------------ ]"
echo "[  Initialization                                              ]"
echo "[                                                              ]"
echo "[  Make sure that you have USB Debugging enabled, you do       ]"
echo "[  allow your computer ADB access by accepting its RSA key     ]"
echo "[  (only needed for Android 4.2.2 or higher) and grant this    ]"
echo "[  ADB process root permissions through superuser.             ]"
echo "[                                                              ]"
echo "[  On your computer, you need adb installed and working        ]"
echo "[ ------------------------------------------------------------ ]"
echo

PS3='Please enter your choice: '
options=("Backup" "Exit")
select opt in "${options[@]}"

do
    case $opt in
		"Backup")
			cd scripts/linux
			./backup.sh $VERSION
			exit
			 ;;
        "Exit")
            break
            ;;
        *) echo invalid option;;
	esac
done 