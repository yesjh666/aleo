#!/usr/bin/env bash

source h-manifest.conf

[[ "$CUSTOM_URL" = "" ]] && echo "Using default CUSTOM_URL" && CUSTOM_URL="stratum+tcp://aleo-asia.f2pool.com:4400"
if echo "$CUSTOM_USER_CONFIG"|grep GPU_INDEX;then
    GPU_INDEX=$(echo "$CUSTOM_USER_CONFIG" |head -1)
fi

conf=""
conf+="ACCOUNT=\"$CUSTOM_TEMPLATE\""$'\n'
conf+="CUSTOM_URL=\"$CUSTOM_URL\""$'\n'
conf+="$GPU_INDEX"$'\n'

echo "$conf" > $CUSTOM_CONFIG_FILENAME