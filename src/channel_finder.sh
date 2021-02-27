#!/bin/bash

# get active wifi interface name 
interface=$(iwgetid | grep -Eo '^[^ ]+')
echo "Your WiFi interface: $interface"

# get SSID of your wifi
ssid=$(iwgetid -r)
ssid=\"${ssid}\"
echo "Your SSID: $ssid"

case "$1" in
	--two)
		max_channel=14
		min_channel=1
		;;
		
	--five)
		max_channel=196
		min_channel=32
		;;

	*)
		max_channel=14
		min_channel=1
		;;
esac

# detect surrounding SSIDs, channels in use and signal strengths
scan_networks() {
	iwlist_out=$(iwlist $interface scan)

	# reset Internal Field Separator (IFS) temporarily to allow SSIDs containing white spaces
	IFS=$'\n'
	#all_ssids=$(echo "$iwlist_out" | grep 'ESSID:' | cut -d '"' -f2)
	#all_ssids=$(echo "$iwlist_out" | grep -o 'ESSID:"[^"]\+"')
	all_ssids=$(echo "$iwlist_out" | grep -oP '(?<=ESSID:).*')
	all_ssids=($all_ssids)
	unset IFS

	channels=$(echo "$iwlist_out" | grep -oP '(?<=Channel:).*')
	channels=($channels)

	quality_weights=$(echo "$iwlist_out" | grep -oP '(?<=Quality=).*' | cut -c1-2)
	quality_weights=($quality_weights)
}

# delete own WiFi SSID to avoid any false computations
ignore_own_network() {
	for i in "${!all_ssids[@]}"
	do
   		if [ "${all_ssids[$i]}" == "$ssid" ]; then
			#my_channel=$(echo "${channels[$i]}")
			#my_quality_weight=$(echo "${quality_weights[$i]}")
			#IFS=$'\n'
			#all_ssids=(${all_ssids[@]/$ssid})
			#unset IFS
			#channels=(${channels[@]/$my_channel})
			#quality_weights=(${quality_weights[@]/$my_quality_weight})
			
			unset all_ssids[$i]
			unset channels[$i]
			unset quality_weights[$i]
   		fi
	done
}

compute_recommendation() {
	declare -A counts
	declare -A weights
	declare -A best_channels=([1]=0 [6]=0 [11]=0)
	echo "Best channels ${!best_channels[*]} ${best_channels[@]}"
	max_quality=70
	
	for i in "${!all_ssids[@]}"
	do
		if (( "${channels[$i]}" <= "$max_channel" )) && (( "${channels[$i]}" >= "$min_channel" )); then
			((counts[${channels[$i]}]++))
			echo ${channels[$i]}
			w=$(echo "${quality_weights[$i]}")
			# normalise quality weights on a [0; 1] scale
			normalised_weight=$(echo "$w/$max_quality" | bc -l)
			weights[${channels[$i]}]=$normalised_weight
		fi
	done
	
	echo "Keys counts ${!counts[*]}"
	echo "Values counts ${counts[@]}"
	
	echo "Keys weights ${!weights[*]}"
	echo "Values weights ${weights[@]}"
	
	# first case if one or more of the best channels are occupied -> choose the one with least co-channel interference
	# based on number of networks and signal strengths
	for i in "${!counts[@]}"
	do
		if [[ "${!best_channels[*]}" =~ "${i}" ]]; then
			best_channels[${i}]=${counts[$i]}
			
		fi
	done
	
	echo "Best channel keys ${!best_channels[*]}"
	echo "Best channel values ${best_channels[@]}"
	
	lowest_occupancy=9999
	rec=()
	for i in "${!best_channels[@]}"
	do
		if (( "${best_channels[$i]}" < "$lowest_occupancy" )); then
			lowest_occupancy=${best_channels[$i]}
			unset rec
			rec+=($i)
		elif (( "${best_channels[$i]}" == "$lowest_occupancy" )); then
			rec+=($i)
		fi
	done
	
	
	
	# second case if 1, 6, 11 are not occupied but other channels are -> choose the channel with the least adjacent
	# channel interference
	
	# third case -> something in between
	
	
	# recommended_channels

}

#  call functions multiple times to update the channels and then recalculate weigths
#for
scan_networks
ignore_own_network
compute_recommendation "$max_channels"
while ! [ "${#all_ssids[@]}" -eq "${#channels[@]}" ]
do
	scan_networks
	ignore_own_network
	compute_recommendation "$max_channels"
done
#done

echo "Neighbouring networks found: "
echo "SSID; Channel; Quality"
for i in "${!channels[@]}"
do
	echo "${all_ssids[$i]}; ${channels[$i]}; ${quality_weights[$i]}"
done

echo -e "\n\nRecommended channel(s): ${rec[@]}"



