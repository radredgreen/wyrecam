# Boot loading and upgrading sequences
## SD card structure

The SD Card contains 3 files
### factory_t31_ZMC6tiIDQN
This is the file that the wyze stock boot loader (and our replacement u-boot) looks for on the SD card.  When the boot loader finds this file it boots the file as a kernel with the following cmdline parameters

```
console=ttyS1,115200n8 mem=64M@0x0 rmem=64M@0x4000000 root=/dev/ram0 rw rdinit=/linuxrc
```

This instructs the kernel to boot from it's own internal initramfs.  factory_t31_ZMC6tiIDQN contains an initramfs which is capable of upgrading the nor flash rom from the MMC image.  This file must be less than 5242880 bytes or the factory u-boot doesn't copy the whole image to ram before trying to boot it.

### nor_full.bin
This file contains the concatenation of the wyrecam u-boot image (including patches for ingenic and to also look for factory_t31_ZMC6tiIDQN), the wyrecam built kernel (without the initramfs) and the wyrecam rootfs.  It the size of the nor flash, so writing this file to the nor will overwrite overlayfs resetting any configuration contained therein.

### upgrade.sh
The rootfs.squashfs and the initramfs boot both look for this file on the SD card and execute it when found.  When first installing on a factory flashed device, this backups the factory image and overwrites the nor flash and configures the device.  Edit this file on the SD card to insert wifi and root passwd credentials.


## Boot procedure to install wyrecam from the factory image
* T31 loads the factory u-boot image from the nor and boots it
* Factory u-boot image looks for factory_t31_ZMC6tiIDQN and boots it with cmdline parameters that instruct it to boot from it's own initramfs
* wyrecam kernel (with initramfs) boots and executes upgrade.sh
* upgrade.sh backs up the factory image (SAVE THIS FROM THE SD CARD TO REVERT LATER)
* upgrade.sh flashes the nor flash with nor_full.bin
* upgrade.sh updates flash image credentials
* upgrade.sh blinks the led to indicate that the upgrade process is complete

## Boot procedure during a normal wyrecam boot
* T31 loads the wyrecam u-boot image from the nor and boots it
* Factory u-boot image looks for factory_t31_ZMC6tiIDQN and doesn't find it, so boots nor kernel
* wyrecam nor kernel (withotu initramfs) boots and executes upgrade.sh
* upgrade.sh doesn't exist so the system continues booting

## Boot procedure during an upgrade from an older wyrecam image
* T31 loads the wyrecam u-boot image from the nor and boots it
* Wyrecam u-boot image looks for factory_t31_ZMC6tiIDQN and boots it with cmdline parameters that instruct it to boot from the internal initramfs
* wyrecam kernel (with initramfs) boots and executes upgrade.sh
* upgrade.sh backs up the old image
* upgrade.sh flashes the nor flash with nor_full.bin

## Boot procedure during an downgrade from wyrecam back to wyze image
* T31 loads the wyrecam u-boot image from the nor and boots it
* Wyrecam u-boot image looks for wyrecam factory_t31_ZMC6tiIDQN and boots it with cmdline parameters that instruct it to boot from the internal initramfs
* wyrecam kernel (with initramfs) boots and executes upgrade.sh
* upgrade.sh backs up the wyrecam image
* upgrade.sh flashes the nor flash with the factory wyze image backed up durint the first install of wyrecam


