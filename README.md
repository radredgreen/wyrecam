# WyreCam: Simple, Secure Home Security Camera
 
WyreCam is an open-source firmware for the Wyze v3 camera that integrates seamlessly with HomeKit Secure Video (HKSV). WyreCam offers enhanced privacy, security, and convenience.

## Benefits of WyreCam HomeKit Secure Video (HKSV)
 
- **End-to-End Encryption**: HKSV ensures that your video recordings are fully encrypted, providing a higher level of privacy and security.
- **Rich Notifications**: Receive detailed notifications that include snapshots and recorded video clips, keeping you informed of important events.
- **iCloud Storage**: Store your recordings securely in iCloud without needing an additional subscription service.
- **Smart Detection**: HKSV can recognize and notify you about specific activities, such as animals, people, and vehicles.
- **Familiar Face Recognition**: Use your iOS photo library to recognize familiar faces in your camera footage.
- **Integration with HomeKit**: Seamlessly integrate with your existing HomeKit setup, enabling you to manage all your smart home devices from one app.
 
## Features
 
- **Video Streaming and Recording**: Secure end-to-end encryption for streaming and recording.
- **HomeKit Pairing**: Fixed pairing code 0107-2024.
- **Jpeg Snapshots**: Capture high-quality images.
- **Audio Streaming**: (Recording and talkback coming soon).
- **Motion Detection**: HomeKit motion notifications.
- **Automatic IR Filter**: The day/night IR filter is enabled based on scene brightness.
- **IR LED Night Vision**: Night vision lights for clear visibility in the dark.
 
## Getting Started
 
### Download the WyreCam Image
 
1. Visit the [Releases Section](https://github.com/radredgreen/wyrecam/releases) of the WyreCam repository.
2. Download the latest WyreCam image file.
 
### Write the Image to an SD Card
 
#### Using Balena Etcher
 
1. Download and install [Balena Etcher](https://www.balena.io/etcher/).
2. Insert your SD card into your computer.
3. Open Balena Etcher, select the downloaded WyreCam image file, select your SD card, and click "Flash".
 
#### Using Raspberry Pi Imager
 
1. Download and install [Raspberry Pi Imager](https://www.raspberrypi.org/downloads/).
2. Insert your SD card into your computer.
3. Open Raspberry Pi Imager, click "Choose OS," select "Use custom," and find the WyreCam image file.
4. Click "Choose SD Card" and select your SD card.
5. Click "Write" to write the image to the SD card.
 
### Setting Up WiFi Credentials
 
1. Insert the SD card into your computer.
2. Open the `update.sh` file in a text editor.
3. Locate the following section in the `update.sh` file:
    ```sh
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
    ```
4. Replace `"SSID"` with your network's SSID and `"PASSWD"` with your network's password.
    ```sh
    # Set the wifi credentials
    if true; then
    cat << EOF > /pivot/etc/wpa_supplicant.conf
    ctrl_interface=/var/run/wpa_supplicant
    ap_scan=1
    network={
    scan_ssid=1
    ssid="your_SSID"
    psk="your_PASSWORD"
    }
    EOF
    fi
    ```
5. Save the file and eject the SD card from your computer.
 
### Install the Image
 
1. Insert the SD card into the camera and power it on. The red LED light will turn on.
2. Wait 10 minutes for the upgrade process to complete. Do not remove power during this time.
3. When the red LED light blinks, unplug the power and remove the SD card.
4. Backup the `spi_backup/backup.bin` file from the SD card for recovery purposes.
 
### Add WyreCam to HomeKit
 
1. Open the Home app on your iPhone or iPad.
2. Tap on the "+" icon and select "Add Accessory."
3. Tap on "More options" to see the accessory.
4. Enter the HomeKit setup code (0107-2024) when prompted.
5. Follow the on-screen instructions to complete the setup.
6. Assign the camera to a room and customize its settings as desired.

https://github.com/user-attachments/assets/b5304535-5445-485d-a184-c80f98ddb3db
 
## Configuration in Home.app
 
- **Night Vision**: Controlled automatically based on the brightness of the scene. The "Night Vision Light" switch in Home.app turns on the infrared LED when the scene is dark.
- **Camera Status Light**: Toggle the red LED on/off to help with reflections if the camera is near a window. Toggling twice flips the image.
- **Invert Image**: Useful for ceiling-mounted cameras. Toggle the Camera Status Light twice to flip the image.
 
## Documentation
 
Refer to the [docs directory](docs/) for more information.
 
## Similar Projects, References, and Credits
 
- [thingino](https://github.com/themactep/thingino-firmware)
- [v3-unlocker](https://git.i386.io/wyze/v3-unlocker)
- [OpenIPC](https://github.com/OpenIPC)
- [t20_rtspd](https://github.com/geekman/t20-rtspd)
- [ingenic_videocap](https://github.com/openmiko/ingenic_videocap)
- [Ingenic-SDK-T31](https://github.com/cgrrty/Ingenic-SDK-T31-1.1.1-20200508)
- [Wyze GPL source](https://support.wyze.com/hc/en-us/articles/360012546832-Open-Source-Software)
- [Dafang-Hacks](https://github.com/Dafang-Hacks)
- [Apple HAP ADK](https://github.com/apple/HomeKitADK)
- [hkcam](https://github.com/brutella/hkcam)
- [hap-nodejs](https://github.com/homebridge/HAP-NodeJS)
- [homebridge-ffmpeg](https://github.com/Sunoo/homebridge-camera-ffmpeg)
- [homebridge-unity](https://github.com/hjdhjd/homebridge-unifi-protect/blob/main/docs/HomeKitSecureVideo.md)
 
## Build Instructions
 
Detailed build instructions have been moved to a dedicated file. Please refer to [BUILD_INSTRUCTIONS.md](build_instructions.md) for step-by-step guidance on building WyreCam from source.
