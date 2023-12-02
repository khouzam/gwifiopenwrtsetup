#! /bin/bash

if [ -z ${1+x} ]; then
    echo "Please specify a name for the AP"
    exit -1
else
    echo "Setting AP name to '${1}'"
fi

SCRIPT_PATH=$(dirname "$0") # relative
SCRIPT_PATH=$(cd "$SCRIPT_PATH" && pwd)
if [[ -z "$SCRIPT_PATH" ]]; then
    # error; for some reason, the path is not accessible
    # to the script (e.g. permissions re-evaled after suid)
    exit 1 # fail
fi

pushd ${SCRIPT_PATH}

IP_ADDR=192.168.1.1

./waitping.sh ${IP_ADDR}

## Copy the environment to the AP
scp -O ./setenv.sh root@${IP_ADDR}:/tmp

## Copy the script to setup the AP
scp -O ./setupconfig.sh root@${IP_ADDR}:/tmp

## Run the script to setup the AP
ssh -t root@${IP_ADDR} "source /tmp/setenv.sh && /tmp/setupconfig.sh ${1}"

echo Setting up secure SSH access
if [[ -f ./openwrt.key.pub ]]; then
    ssh root@${IP_ADDR} "tee -a /etc/dropbear/authorized_keys" <./openwrt.key.pub
fi

echo "Setup complete, rebooting"
ssh root@${IP_ADDR} reboot

sleep 5

./waitping.sh ${IP_ADDR}

echo "Setting up the network"
scp -O ./setenv.sh root@${IP_ADDR}:/tmp
scp -O ./setupnetwork.sh root@${IP_ADDR}:/tmp
ssh -t root@${IP_ADDR} "source /tmp/setenv.sh && /tmp/setupnetwork.sh ${1}"

echo "Rebooting the AP has been fully configured and can be plugged into it's correct spot"
ssh -t root@${IP_ADDR} reboot

popd