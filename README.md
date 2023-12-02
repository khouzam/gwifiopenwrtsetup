# GWiFi OpenWRT
Setup to automate flashing and configuring my Google WiFi (gale) pucks with [OpenWRT](https://openwrt.org/toh/google/wifi)

The repo in organized as follows.
1. img contains the binary images to recover and the current openWRT image that is used to flash.
2. scripts contains the different scripts that configure the access points.

## Preparing the USB devices
1. Unizp and flash a USB drive using the image, substitute `sdx` with the appropriate drive eg: `/dev/sdb/`
```
unzip -p chromeos_9334.41.3_gale_recovery_stable-channel_mp.bin.zip | sudo dd of=/dev/<sdx> bs=1M status=progress
```

2. Flash another USB drive with the OpenWRT image
```
unzip -p openwrt-23.05.2-ipq40xx-chromium-google_wifi-squashfs-factory.bin.zip | sudo dd of=/dev/<sdx> bs=1M status=progress
```

## Flashing the device
Follow the instructions https://openwrt.org/toh/google/wifi to factory reset and then flash OpenWRT onto the access point. Once the device is booted, you can start using the scripts to program, flash and configure  (steps 7 to program and the rest can be skipped).

In the `scripts` folder. Edit and fill the `setenv.sh` file for the network configuration

If you want to enable public key ssh access to the AP, create a file `openwrt.key.pub` in the `scripts` folder with the ssh public key.

__Connect the LAN port to your computer and the WAN port to the network__

Run `./flashap.sh <APName>` to start the flashing process.

__Once flashed, `./startsetup.sh` can be used to reconfigure the AP__


## Configuration
This setup will create 
1. Main WiFi on the default VLAN with 2.4GHz and 5GHz mixed bands and WPA3 mixed encryption
2. Guest WiFi on a separate VLAN with 2.4GHz and 5GHz mixed bands with WP3 mixed encryption
3. IOT WiFi on a separate VLAN only on the 2.4GHz band with WPA2 encryption.
4. The AP is a DHCP client device on the main network (IOT and Guest cannot reach the AP)
5. WAN and LAN ports are bridged

This can easily be changed through `setenv.sh` and `setupnetwork.sh`
