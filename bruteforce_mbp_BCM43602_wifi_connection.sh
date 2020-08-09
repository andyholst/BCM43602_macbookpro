#!/usr/bin/env bash

# Argument 1: ESSID for 2 Ghz band
# Argument 2: ESSID for 5 Ghz band
# Argument 3: WPA2 password

NUMBER=0
HEX_NUMBER=0

nmcli c add type wifi con-name $1 ifname wlp3s0 ssid $1
nmcli con modify $1 wifi-sec.key-mgmt wpa-psk
nmcli con modify $1 wifi-sec.psk $3
nmcli con up $1

ping -w3 google.com
ESSID1_STATUS=$?

nmcli c delete $1

nmcli c add type wifi con-name $2 ifname wlp3s0 ssid $2
nmcli con modify $2 wifi-sec.key-mgmt wpa-psk
nmcli con modify $2 wifi-sec.psk $3
nmcli con up $2

ping -w3 google.com
ESSID2_STATUS=$?

nmcli c delete $2

while [[ $ESSID1_STATUS -ne 0  || $ESSID2_STATUS -ne 0 ]] && [ $NUMBER -lt 4294967295 ]
do
	((NUMBER=NUMBER+1))
	HEX_NUMBER=$(printf "%08X" ${NUMBER})
	sed -i "s/boardflags3=0x.*/boardflags3=0x$HEX_NUMBER/g" config/brcmfmac43602-pcie.txt
	sudo cp config/brcmfmac43602-pcie.txt /lib/firmware/brcm/brcmfmac43602-pcie.txt
	sudo rmmod brcmfmac && sudo modprobe brcmfmac

	nmcli c add type wifi con-name $1 ifname wlp3s0 ssid $1
	nmcli con modify $1 wifi-sec.key-mgmt wpa-psk
	nmcli con modify $1 wifi-sec.psk $3
	nmcli con up $1

	ping -w3 google.com
	ESSID1_STATUS=$?

	nmcli c delete $1

	nmcli c add type wifi con-name $2 ifname wlp3s0 ssid $2
	nmcli con modify $2 wifi-sec.key-mgmt wpa-psk
	nmcli con modify $2 wifi-sec.psk $3
	nmcli con up $2

	ping -w3 google.com
	ESSID2_STATUS=$?

	nmcli c delete $2
done