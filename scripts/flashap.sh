#! /bin/bash
SCRIPT_PATH=$(dirname "$0") # relative
SCRIPT_PATH=$(cd "$SCRIPT_PATH" && pwd)
if [[ -z "$SCRIPT_PATH" ]]; then
    # error; for some reason, the path is not accessible
    # to the script (e.g. permissions re-evaled after suid)
    exit 1 # fail
fi

if [[ "$GALE_ENV_SETUP" -ne "1" ]]; then
    echo Please fill out setenv.sh and invoke it before starting to flash a device
    exit 1 # fail
fi

pushd $SCRIPT_PATH

if [ -z ${1+x} ]; then
    echo "Please specify a name for the AP"
    exit -1
else
    echo "Setting AP name to '${1}'"
fi

IP_ADDR=192.168.1.1

./waitping.sh ${IP_ADDR}

## Extract and copy the firmware
unzip -p ../img/${GALE_OPENWRT_BIN_ZIP} | ssh root@${IP_ADDR} "cat > /tmp/openwrt.bin"

## Write firmware to eMMC and clobber secondary GPT at end of eMMC
echo "Writing firmware to the device"
ssh root@${IP_ADDR} -C "dd if=/dev/zero bs=512 seek=7634911 of=/dev/mmcblk0 count=33 && \
dd if=/tmp/openwrt.bin of=/dev/mmcblk0"

## Ideally, we might add a GPT repair step, so primary and alternate are intact, but this isn't strictly necessary.
echo "Resizing the disk"
ssh root@${IP_ADDR} -C "opkg update && opkg install cfdisk resize2fs"

## Resize the second partition to use the whole space and reboot into the flashed device
ssh -t root@${IP_ADDR} "cfdisk /dev/mmcblk0"

## Reboot
echo "Rebooting"
ssh root@${IP_ADDR} reboot

sleep 5
./waitping.sh ${IP_ADDR}

echo "Starting the AP setup"
./startsetup.sh ${1}

popd
