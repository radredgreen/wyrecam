
## In progress
Package and push

## MVP for release 1.0: BASIC BUILD AND RTSP STREAMING
* DONE: Basic RTSP needs to work at h264 and 1080p
* DONE: Rename all references from wyzev3 to wyzec3
* DONE: ./building.sh t31_wyzec3 needs to build a bootloader, kernel and image that work out of the box
* DONE: Build process needs to output a SD card image that will update a wyzec3
* DONE: Minimize changes from OpenIPC: clean out LTRACE and V4L2LOOPBACK packages
* DONE: Write readme.md
* DONE: Copy MAC address from existing firmware (giving up, using the wifi card mac)
* DONE: Secure root password - set from update.sh
* DONE: Wifi configuration from sd card
* DONE: Rtsp works on boot with no interaction
* DONE: Move development packages (ex: t31-rtspd) into wyrecam/general/packages, else push these to githib
* DONE: ntpd getting time from 0.time.openipc.org, moved to openwrt.ntp.org

DONE: Figure out how we want to configure an unconfigured (freshly written) flash device. In order of preference
* THIS: Copy configuration from SD Card?
* Open WIFI AP then configure via ssh
* Serial port is a fall back, but the goal is to never have to open the camera

DONE: Then remove credentials from update.sh

## TODO for release 2.0 
### DONE: Determine a video pipeline
* DONE-THIS: Build monolithic application in user domain (least modular)
	* (+) Raw h264/5 nalu to network sockets
	* (+) Highest performance 
	* (+) Perhaps use something like smolrtspd
	* (-) Root running daemons on external ports
* t31_rtspd (ingenic sample -> fifo -> live555 rtspd)
	* (+) Already done
	* (-) Live555 crashing on sdp snprintf (hacky workaround), maybe due to musl?
	* (-) rtspd runs as root
	* (-) rtspd not needed for homekit
	* Benchmark 25% idle cpu when streaming 1080p 30hz 2MBps h264 stream
* ingenic sample -> fifo -> ffmpeg configured by homekit
	* (+) ffmpeg is used by most homekit libraries (hapnodejs, homeassistant, hkcam)
	* (+) root not running server daemons
	* (-) extra (not zerocopy) buffer copying in v4l2loopback
	* (-) probably need a configuration file to setup the video pipeline
* ingenic_videocap_t31 -> v4l2loopback -> ffmpeg for homekit and ? for rtspd 
	* (+) standard linux video intereface
	* (+) ffmpeg is used by most homekit libraries (hapnodejs, homeassistant, hkcam)
	* (+) root not running server daemons
	* (-) extra (write vs mmap) buffer copying in v4l2loopback
	* (-) probably need a configuration file to setup the video pipeline
* new ingenic_v4l2 kernel module -> v4l2 interface -> ffmpeg for homekit and ? for rtspd (most modular)
	* (+) probably highest performance v4l2 path (zero copy)
	* (+) could integrate the other libimp functions in the module (motion, speaker, microphone, HKSV DVR)
	* (+) ffmpeg controls video parameters through ioctl instead of configuration file
	* (+) configure in/out rtspd/homekit via buildroot configuration files
	* (-) most work
	* (-) libimp.so can't be linked in kernel module - something-something libimp.a?

## Future: Build compiled blobs from scratch - help wanted!
```audio.ko 
gpio.ko
atbm603x_wifi_sdio.ko
rtl8189ftv.ko
sinfo.ko
avpu.ko
mmc_detect_test.ko
sensor_gc2053_t31.ko
tx-isp-t31.ko
libalog.so
libaudioProcess.so
libimp.so
libsysutils.so
gc2053-t31.bin
speaker_ctl.ko
sample_pwm_core.ko
sample_pwm_hal.ko
```

## Future: Determine how to configure the camera
* wifi credentials
* root passwd
* wired configuration
* frame rate, resolution, encoder settings
* motion detection sensitivity and ROI, rate limiting
* anything on the OSD?
* reset hk pairing

## Determine how to handle GPIO
* DONE (thanks geekman!): how is night vision going to be controlled, IRLED, IRCUT filter
* Status LED x2, doorbell button

## Future: Audio (mic -> videofeed)
* Get alsa microphone working
* Mux data into rtsp feed
* flaac

## Future: Audio return (return audio -> speaker)
* Get speaker working
* Play sound clip

## Future: Lower priority
* Shorten openipc's sensor probing process by cutting out unused sensors
* DONE: Adopt Wyze's method and script for probing wifi cards and installing the correct driver, then remove the hardcoded drivers from /etc/modules
* Auto update mechanism?
* DONE: Hostname, login banner, cmd prompt in uboot branding from openipc to wyrecam

## Low priority
* Anything to do with docker
* Run "grep -rn . -e TODO" at the top level 
* fwprintenv isn't interfaceing correctly with the uboot envoronment - not currently using fwprintenv. Fix uboot or remove fwprintenv.

