#!/bin/bash

source h-manifest.conf
source $CUSTOM_CONFIG_FILENAME
APPNMAE=$CUSTOM_NAME
APP_PATH=./$APPNMAE

pkill -9 $APPNMAE
if [[ "$GPU_INDEX" = "" ]]; then
    $APP_PATH -u $CUSTOM_URL -w $ACCOUNT >>${CUSTOM_LOG_BASENAME}1.log 2>&1
    echo "$APP_PATH -u $CUSTOM_URL -w $ACCOUNT >> ${CUSTOM_LOG_BASENAME}1.log 2>&1"
else
    $APP_PATH -u $CUSTOM_URL -w $ACCOUNT -d $GPU_INDEX >>${CUSTOM_LOG_BASENAME}1.log 2>&1
    echo "$APP_PATH -u $CUSTOM_URL -w $ACCOUNT -d $GPU_INDEX >> ${CUSTOM_LOG_BASENAME}.log 2>&1"
fi
