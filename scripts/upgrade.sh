echo "UPGRADE SCRIPT START"
# Turn on the red led to show that we're working
echo 38 > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio38/direction
echo 0 > /sys/class/gpio/gpio38/value

# Backup the existing nor flash to the SD Card
if true; then
  mkdir -p /mnt/mmcblk0p1/spi_backups
  dd if=/dev/mtdblock0 of=/mnt/mmcblk0p1/spi_backups/backup.bin bs=32768
  sync
  sync
  sync
  sleep 5
fi

# Flash the nor flash with nor_full.sh
if true; then
  flashcp -v /mnt/mmcblk0p1/nor_full.bin /dev/mtd0
  sync
  sync
  sync
  sleep 5
fi

# Pivot to the nor flash filesystem
if true; then
  #mtd0 is already taken, so can't mtdpart add uboot
  mtdpart add /dev/mtd0 env 0x40000 0x10000
  mtdpart add /dev/mtd0 kernel 0x50000 0x300000
  mtdpart add /dev/mtd0 rootfs 0x350000 0xa00000
  mtdpart add /dev/mtd0 rootfs_data 0xD50000 0x2B0000
  mtdinfo

  mkdir /newroot
  mkdir /pivot

  mount /dev/mtdblock3 /newroot

  mtdblkdev=`awk -F ':' '/rootfs_data/ {print $1}' /proc/mtd | sed 's/mtd/mtdblock/'`
  mtdchrdev=`grep 'rootfs_data' /proc/mtd | cut -d: -f1`
  mount -t jffs2 /dev/${mtdblkdev} /newroot/overlay
  
  if [ $? -ne 0 ] || { dmesg | grep "jffs2.*: Magic bitmask.*not found" > /dev/null 2>&1; } then
        echo "jffs2 health check error, format required!"
        flash_eraseall -j /dev/${mtdchrdev}
        echo "Done! Remounting..."
        mount -t jffs2 /dev/${mtdblkdev} /newroot/overlay || mount -t tmpfs tmpfs /newroot/overlay || exit
        if ! cat /proc/mounts | grep ${mtdblkdev}; then
          echo "--------------------------------"
          echo "Crash - your flash in the trash!"
          echo "--------------------------------"
        fi
  fi

  mount -t overlayfs overlayfs -o lowerdir=/newroot,upperdir=/newroot/overlay,ro /pivot || { umount /newroot/overlay; exit; }
  mount -o remount,rw /pivot

  # Can't pivot from initramfs
  # https://unix.stackexchange.com/questions/455223/pivot-root-from-initramfs-to-new-root-error-invalid-argument
  # pivot_root /pivot /pivot/rom
fi

# Set the root passwd
if true; then
  #(tr -cd '[:alnum:]' < /dev/urandom | fold -w8 | head -n 1)
  echo "root:passwd" | chpasswd
  cp /etc/shadow /pivot/etc/shadow
fi

# Set the wifi credentials
if true; then
cat << EOF > /pivot/etc/wpa_supplicant.conf
ctrl_interface=/var/run/wpa_supplicant
ap_scan=1

network={
 scan_ssid=1
 ssid="SSID"
 psk="PASSWD"
}
EOF
fi

# Enable dropbear (ssh)
if false; then
  chmod 644 /pivot/etc/init.d/S50dropbear
#else
#  chmod 755 /pivot/etc/init.d/S50dropbear
fi


echo 38 > /sys/class/gpio/export

# Blink the light forever (don't boot further)
if true; then
  sync
  sync
  sync
  while [ 1 ]; do
       echo 0 > /sys/class/gpio/gpio38/value
       sleep 1
       echo 1 > /sys/class/gpio/gpio38/value
       sleep 1
  done
fi

echo 1 > /sys/class/gpio/gpio38/value


echo "UPGRADE SCRIPT FINISHED"


