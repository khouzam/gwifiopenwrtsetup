#! /bin/bash

if [ -z ${1+x} ]; then
    echo "Please specify ping address"
    exit -1
else
    echo "Pinging '${1}'"
fi

FOUND=1
echo -n "waiting for ${1} ..."
while ((${FOUND} == 1)); do
    if ping -c 1 -W 1 ${1} &>/dev/null; then
        echo "${1} is back online!"
        FOUND=0
    else
        echo -n "."
        sleep 1
    fi
done

echo Giving the device 5 seconds to fully be ready
sleep 5
