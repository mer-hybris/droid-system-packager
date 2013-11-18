#!/bin/sh

DPATH=$1

FILES="$DPATH/init*rc"

INITLINES=(

"mkdir /mnt "
"write /proc/cpu/alignment"
# Services that should not exist in init
"service wpa_supplicant"
"service p2p_supplicant"
"service dhcpcd_"
"service iprenew_"
"service dhcpcd_"
"start ueventd"
"symlink /system/etc /etc"
"mount rootfs rootfs / ro remount"
"service ueventd "
"service console "
"service servicemanager "
"service vold "
"service netd "
"service debuggerd "
"service surfaceflinger "
"service zygote "
"service drm "
"service media "
"service bootanim "
"service shutdownanim "
"service dbus "
"service bluetoothd "
"service installd "
"service racoon "
"service mtpd "
"service keystore "
"service dumpstate "
"service sshd "
"service mdnsd "
"service qrngd "
"service time_daemon"
"service charger"
)

RETVAL=0
  
for LINE in "${INITLINES[@]}"; do
  #echo -e "\nChecking if '$LINE' is found from '$FILES'.."
  linesfound=$(grep -n "$LINE" $FILES | grep -v "[0-9]:[ \t]*#")
  if [ -n "$linesfound" ]; then
    echo -e "\nERROR: Found unallowed line(s) from $FILES:\n $linesfound"
    RETVAL=-1
  fi 
done

exit $RETVAL


