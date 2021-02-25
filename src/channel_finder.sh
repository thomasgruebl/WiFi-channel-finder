#!/bin/bash

# get active wifi interface name 
interface=$(iwgetid | grep -Eo '^[^ ]+')
echo "Your WiFi interface: $interface"

# get SSID of your wifi
ssid=$(iwgetid -r)
echo "Your SSID: $ssid"

# detect surrounding SSIDs, channels in use and signal strengths
scan_networks() {
	all_ssids=$(iwlist $interface scan | grep -oP '(?<=ESSID:).*' | tr -d '"')
	all_ssids=($all_ssids)

	channels=$(iwlist $interface scan | grep -oP '(?<=Channel:).*')
	channels=($channels)

	quality_weights=$(iwlist $interface scan | grep -oP '(?<=Quality=).*' | cut -c1-2)
	quality_weights=($quality_weights)
}
scan_networks
while [ ${#all_ssids[@]} != ${#channels[@]} ]; do
	scan_networks
	echo "${#all_ssids[@]} ${#channels[@]}"
done

echo "Neighbouring networks found: "
for i in "${!all_ssids[@]}"
do
	echo "${all_ssids[$i]} ${channels[$i]} ${quality_weights[$i]}"
done

# store SSIDs, channels and signal strengths in arrays (or dicts) and check if they have the same length
