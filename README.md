# wyrecam
Wyrecam is an open source, vanilla HomeKit Secure Video (HKSV) firmware for the wyze v3 camera

Demonstration:

[![Watch the video]](https://github.com/user-attachments/assets/de1e8832-b0f6-4e12-b284-b7f8cb89f500)


## Features
* Video streaming (streaming and recording) 
* Secure end-to-end (camera to iOS device or home hub) (Streaming: AES_256_CM_HMAC_SHA1_80, Recording: CHACHA20_POLY1305) encryption provided by MBEDTLS
* Homekit pairing (fixed pairing code 0107-2024)
* Jpeg snapshots 
* Audio (streaming, not recording or talkback, yet)
* Motion detection and with homekit motion notifications
* Day/Night IR filter automatically enabled based on the brightness of the scene
* IR LED Night vision lights

## This project aims for the following:
* 100% open source (readable and inspectable) software 
	* U-Boot: Control from the very first command executed
	* Kernel: Fully open source kernel software
	* Drivers and SOC libraries are a work in progress (see TODO.md for remaining BLOBs)
	* Video and audio streaming software
	* No closed source or precompiled toolchains
* First class support for HomeKit
	* Goal to support HKSV natively from the camera with high performance
	* Can be disabled through configuration
* As secure as possible
	* Only SSHD (dropbear) and HomeKit (Apple APK) listening ports running.  SSHD is disabled by default.
	* Secure root password setup at install
* No anti-features
	* No web configuration - you'll have to ssh into the camera or use and SD card to configure it
	* No method of auto-update (why should you trust this repo not to be hacked?) - you'll have to update manually
	* No tftp boot image requests
	* Designed to work without an internet connection (on a dedicated VLAN for example)
* Built on cheap (WYZEC3, etc) cameras for low cost

## Building
The first two optional steps build the factory boot kernel for initial boot from the sd card

TODO This first step will probably error out trying to build an sd card image - that's ok for now
```
(optional) ./building.sh t31_install_wyzec3
(optional) cp output/images/uImage factory_t31_ZMC6tiIDQN
./building.sh t31_wyzec3
```
Copy the image to an SD card (know what you're doing)
```
dd if=output/image/wyrecam_install.img of=/dev/<sdb> bs=512
```

## Configure and Install

### Edit update.sh
Insert the new sd card into a computer and edit update.sh to add the wifi credentials and a root passwd (search for passwd and replace with your new passed)

Optionally disable ssh and enable blinking lights to see when the flash process is done

Unmount the sd card and eject from the computer

### Install the image

Insert the sd card into the camera and power on.  Red LED light will turn on

DO NOT REMOVE POWER for 10 minutes - this build has no recovery mechanisms from interupted upgrades.

Upgrade finish times
```
Boot: 0:09 m
Flash Backup: 2:03 m
Flash Erase: 2:49 m
Flash Write: 3:09 m
Flash Verify: 3:14 m
Flash Finish configure: 3:21 m
Boot Compete: 4:00 m
```

Red LED light blinks.  Unplug power.

Remove sd card from the camera and backup spi_backup/backup.bin  I recommend saving this with the filename of the MAC of the camera.  This file can be used to recover the the camera to the original firmware - just rename the file to nor_full.bin, load it to the sd card and reflash.

### Add to HomeKit
See the video above.  The pairing code is 0107-2024

## Configuration in Home.app
### Night Vision
Night mode is controlled automatically based on the brightness of the scene.  Additionally, the home app has a switch for "Night Vision Light" which will turn on the infrared LED when the scene is dark.

### Camera Status Light
The Camera Status Ligth swich is used to turn on and off the red LED on the front of the camera.  This can be helpful if the camera is next to a window and sees the reflection of the LED. Toggling this twice flips the image. Which brings us to...

### Invert the image
If the camera is mounted from the ceiling, it can be useful to flip the image.  Toggling the Camera Status Light twice will flip the image.


## Documentation
See the docs directory for more documentation

## Similar projects, references and credits
### v3-unlocker
https://git.i386.io/wyze/v3-unlocker

U-boot used and the method of creating an SD card were borrowed from wyrecam

### OpenIPC
The point-of-departure for wyrecam.  This project aims to be mergable with OpenIPC down the road but will remain separate until all components of OpenIPC (especially Majestic) are fully open source.

### t20_rtspd
https://github.com/geekman/t20-rtspd, basis of the basic rtsp streamer used in rel 1.  It looks like this supports T31 now as well.  Go here for an RTSP streamer

### ingenic_videocap and openmiko
https://github.com/openmiko/ingenic_videocap, an alternative v4l2 video pipeline 

### Ingenic-SDK-T31
https://github.com/cgrrty/Ingenic-SDK-T31-1.1.1-20200508, thanks cgrrty for posting this

### Wyze GPL source code links
https://support.wyze.com/hc/en-us/articles/360012546832-Open-Source-Software, thanks wyze and GPL

### Dafang-Hacks
Several places refer to this repository although it was not used in the developemnt of WyreCam
https://github.com/Dafang-Hacks

### Apple HAP ADK
https://github.com/apple/HomeKitADK, likely the basis of homekit functionality in future releases
see joebelford's useful fork: https://github.com/joebelford/HomeKitADK and https://github.com/joebelford/homekit_camera

### hkcam
https://github.com/brutella/hkcam, a camera project that I used previously

### hap-nodejs
https://github.com/homebridge/HAP-NodeJS, and homebridge, camera projects I used previously

### homebridge-ffmpeg
https://github.com/Sunoo/homebridge-camera-ffmpeg, a camera project I used previously

### homebridge-unity
https://github.com/hjdhjd/homebridge-unifi-protect/blob/main/docs/HomeKitSecureVideo.md and all the folks that got hksv to work on homebridge showing that this project was feasable



