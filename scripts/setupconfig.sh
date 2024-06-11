if [ -z ${1+x} ]; then
    echo "Please specify a name for the AP"
    exit -1
else
    echo "Setting AP name to '${1}'"
fi

# Install packages
echo Installing Packages
opkg remove wpad-basic-mbedtls
opkg update
opkg install luci luci-ssl wpad-mbedtls dawn luci-app-dawn usteer luci-app-usteer

echo Installed the packages. Configuring device
sleep 3

# Set System
uci set system.@system[0].hostname="${1}"
uci set system.@system[0].timezone="${GALE_TIMEZONE}"
uci set system.@system[0].zonename="${GALE_ZONENAME}"

# Configure LEDs
uci add system led # =cfg038bba
uci set system.@led[-1].name='Connected Blue'
uci set system.@led[-1].sysfs='LED0_Blue'
uci set system.@led[-1].trigger='netdev'
uci set system.@led[-1].dev='lan'
uci add_list system.@led[-1].mode='link'
uci add system led # =cfg048bba
uci set system.@led[-1].name='Connected Green'
uci set system.@led[-1].sysfs='LED0_Green'
uci set system.@led[-1].trigger='netdev'
uci set system.@led[-1].dev='lan'
uci add_list system.@led[-1].mode='link'
uci add system led # =cfg058bba
uci set system.@led[-1].name='Disconnected'
uci set system.@led[-1].sysfs='LED0_Red'
uci set system.@led[-1].trigger='default-on'

uci commit system
