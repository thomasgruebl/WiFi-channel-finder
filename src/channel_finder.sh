#!/bin/bash

# get active wifi interface name 
interface=$(iwgetid | grep -Eo '^[^ ]+')
echo "Your WiFi interface: $interface"

# get SSID of your wifi
ssid=$(iwgetid -r)
echo "Your SSID: $ssid"

# detect surrounding SSIDs, channels in use and signal strengths
scan_networks() {
	iwlist_out=$(iwlist $interface scan)

	IFS_backup=$IFS
	IFS=$'\n'
	all_ssids=$(echo "$iwlist_out" | grep 'ESSID:' | cut -d '"' -f2)
	all_ssids=($all_ssids)
	IFS=$IFS_backup

	channels=$(echo "$iwlist_out" | grep -oP '(?<=Channel:).*')
	channels=($channels)

	quality_weights=$(echo "$iwlist_out" | grep -oP '(?<=Quality=).*' | cut -c1-2)
	quality_weights=($quality_weights)
}
scan_networks

echo "Neighbouring networks found: "
for i in "${!channels[@]}"
do
	echo "${all_ssids[$i]} ${channels[$i]} ${quality_weights[$i]}"
done

# store SSIDs, channels and signal strengths in arrays (or dicts) and check if they have the same length
