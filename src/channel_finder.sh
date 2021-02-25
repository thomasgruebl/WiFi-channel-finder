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

	# reset Internal Field Separator (IFS) temporarily to allow SSIDs containing white spaces
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

ignore_own_network() {
	for i in "${!all_ssids[@]}"
	do
   		if [[ "${all_ssids[$i]}" = "$ssid" ]]; then
			my_channel=$(echo "${channels[$i]}")
			my_quality_weight=$(echo "${quality_weights[$i]}")
			all_ssids=(${all_ssids[@]/$ssid})
			channels=(${channels[@]/$my_channel})
			quality_weights=(${quality_weights[@]/$my_quality_weight})
   		fi
	done
}

scan_networks
ignore_own_network

echo "Neighbouring networks found: "
for i in "${!channels[@]}"
do
	echo "${all_ssids[$i]} ${channels[$i]} ${quality_weights[$i]}"
done



#  call scan_networks multiple times to update the channels and then recalculate weigths
