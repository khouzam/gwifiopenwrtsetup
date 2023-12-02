echo Setting up the network

# DHCP
uci delete dhcp.lan
uci delete dhcp.wan
uci commit dhcp
service dnsmasq restart

# Set LAN and WAN =cfg030f15
uci add_list network.@device[0].ports='lan'
uci add_list network.@device[0].ports='wan'
uci delete network.lan.ip6assign
uci delete network.wan
uci delete network.wan6

# Setup Guest VLAN
uci add network device # =cfg070f15
uci set network.@device[-1].type='bridge'
uci set network.@device[-1].name='br-guest'
uci add_list network.@device[-1].ports=lan.${GALE_GUEST_WIFI_VLAN}
uci set network.guest=interface
uci set network.guest.proto='none'
uci set network.guest.device='br-guest'
uci set network.guest.hostname='*'

# Setup IOT VLAN
uci add network device # =cfg0b0f15
uci set network.@device[-1].type='bridge'
uci set network.@device[-1].name='br-iot'
uci add_list network.@device[-1].ports=lan.${GALE_IOT_WIFI_VLAN}
uci set network.iot=interface
uci set network.iot.proto='none'
uci set network.iot.device='br-iot'
uci set network.iot.hostname='*'

uci commit network

echo LAN configured, setting up WiFi
sleep 3

# Set Wireless Radios
uci set wireless.radio0.country='US'
uci set wireless.radio0.channel='auto'
uci set wireless.radio0.htmode='HT20'
uci set wireless.radio0.cell_density='0'
uci delete wireless.default_radio0
uci delete wireless.radio0.disabled

uci set wireless.radio1.country='US'
uci set wireless.radio1.channel='auto'
uci set wireless.radio1.htmode='VHT80'
uci set wireless.radio1.cell_density='0'
uci delete wireless.radio1.disabled
uci delete wireless.default_radio1

# Create main WiFi networks
uci set wireless.mainwifi24=wifi-iface
uci set wireless.mainwifi24.device='radio0'
uci set wireless.mainwifi24.mode='ap'
uci set wireless.mainwifi24.ssid="${GALE_MAIN_WIFI_NAME}"
uci set wireless.mainwifi24.encryption="${GALE_MAIN_WIFI_ENCRYPTION}"
uci set wireless.mainwifi24.key="${GALE_MAIN_WIFI_PASSWORD}"
uci set wireless.mainwifi24.network='lan'
# uci set wireless.mainwifi24.ieee80211r='1'
# uci set wireless.mainwifi24.ft_over_ds='0'
# uci set wireless.mainwifi24.ft_psk_generate_local='1'
# uci set wireless.mainwifi24.ieee80211k='1'

uci set wireless.mainwifi5=wifi-iface
uci set wireless.mainwifi5.device='radio1'
uci set wireless.mainwifi5.mode='ap'
uci set wireless.mainwifi5.ssid="${GALE_MAIN_WIFI_NAME}"
uci set wireless.mainwifi5.encryption="${GALE_MAIN_WIFI_ENCRYPTION}"
uci set wireless.mainwifi5.key="${GALE_MAIN_WIFI_PASSWORD}"
uci set wireless.mainwifi5.network='lan'
# uci set wireless.mainwifi5.ieee80211r='1'
# uci set wireless.mainwifi5.ft_over_ds='0'
# uci set wireless.mainwifi5.ft_psk_generate_local='1'
# uci set wireless.mainwifi5.ieee80211k='1'

## Setup the Guest network as a new SSID and VLAN
uci set wireless.guest24=wifi-iface
uci set wireless.guest24.device='radio0'
uci set wireless.guest24.mode='ap'
uci set wireless.guest24.ssid="${GALE_GUEST_WIFI_NAME}"
uci set wireless.guest24.encryption="${GALE_GUEST_WIFI_ENCRYPTION}"
uci set wireless.guest24.key="${GALE_GUEST_WIFI_PASSWORD}"
uci set wireless.guest24.network='guest'
# uci set wireless.guest24.ieee80211r='1'
# uci set wireless.guest24.ft_over_ds='0'
# uci set wireless.guest24.ft_psk_generate_local='1'
# uci set wireless.guest24.ieee80211k='1'

uci set wireless.guest5=wifi-iface
uci set wireless.guest5.device='radio1'
uci set wireless.guest5.mode='ap'
uci set wireless.guest5.ssid="${GALE_GUEST_WIFI_NAME}"
uci set wireless.guest5.encryption="${GALE_GUEST_WIFI_ENCRYPTION}"
uci set wireless.guest5.key="${GALE_GUEST_WIFI_PASSWORD}"
uci set wireless.guest5.network='guest'
# uci set wireless.guest5.ieee80211r='1'
# uci set wireless.guest5.ft_over_ds='0'
# uci set wireless.guest5.ft_psk_generate_local='1'
# uci set wireless.guest5.ieee80211k='1'

# Set up 2.4 GHz IOT WiFi
uci set wireless.iot24=wifi-iface
uci set wireless.iot24.device='radio0'
uci set wireless.iot24.mode='ap'
uci set wireless.iot24.ssid="${GALE_IOT_WIFI_NAME}"
uci set wireless.iot24.encryption="${GALE_IOT_WIFI_ENCRYPTION}"
uci set wireless.iot24.key="${GALE_IOT_WIFI_PASSWORD}"
uci set wireless.iot24.network='iot'

uci commit wireless

# Switch the DHCP Client
echo Switching the device to be a DHCP client
uci set network.lan.proto='dhcp'
uci commit network
