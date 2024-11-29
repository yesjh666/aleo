#!/usr/bin/env bash
source $MINER_DIR/$CUSTOM_MINER/h-manifest.conf

gpu_stats_nvidia=$(jq '[.brand, .temp, .fan, .power, .busids, .mtemp, .jtemp] | transpose | map(select(.[0] == "nvidia")) | transpose' <<< $gpu_stats)
gpu_temp=$(jq -c '[.[1][]]' <<< "$gpu_stats_nvidia")
gpu_fan=$(jq -c '[.[2][]]' <<< "$gpu_stats_nvidia")
gpu_bus=$(jq -c '[.[4][]]' <<< "$gpu_stats_nvidia")
gpu_count=$(jq '.busids | select(. != null) | length' <<< $gpu_stats)

algo='aleo'
version="3.0.14"
stats="null"
unit="S/s"
khs=0

total_khs=$(tail -n 200 /var/log/miner/custom/aleominer1.log |grep "Speed(S/s)" | awk 'END {print}'| awk '{print $3}')
khs=$(echo "scale=5; $total_khs / 1000" | bc)
total=$khs

declare -A hs

readarray -t gpu_values < <(tail -n 200 /var/log/miner/custom/aleominer1.log | sed -n '/GPU/,/Speed/p'| head -n -1 | tac | awk '/Speed/{exit} {print}'| tac | sed -E 's/.* ([0-9]+).*/\1/')

tmp=$(tail -n 200 /var/log/miner/custom/aleominer1.log | grep -oP '\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}' | tail -n 1)
start=$(date +%s -d "$tmp")
now=$(date +%s)
uptime=$((now - start))

gpu_count=${#gpu_values[@]}

for (( i=0; i < ${gpu_count}; i++ )); do
   busid=$(jq .[$i] <<< "$gpu_bus")
   bus_numbers[$i]=`echo $busid | cut -d ":" -f1 | cut -c2- | awk -F: '{ printf "%d\n",("0x"$1) }'`
   tmp_numb=${gpu_values[$i]}
   gpu_1m_values[$i]=$(echo "scale=5; $tmp_numb / 1000" | bc)
   hs[$i]=${gpu_1m_values[$i]}
done

stats=$(jq -nc \
        --arg total_khs "$khs" \
        --arg khs "$khs" \
        --arg hs_units "$unit" \
        --argjson hs "$(echo "${hs[@]}" | jq -Rcs 'split(" ")')" \
        --argjson temp "${gpu_temp}" \
        --argjson fan "${gpu_fan}" \
		--arg uptime "$uptime" \
        --arg ver "$version" \
        --arg algo "$algo" \
        --argjson bus_numbers "`echo ${bus_numbers[@]} | tr " " "\n" | jq -cs '.'`" \
        '{$khs, $khs, "hs_units":$hs_units, $hs, $temp, $fan, $uptime, "ver":$ver, "algo":$algo, $bus_numbers}')


echo "$stats"
echo $khs