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
