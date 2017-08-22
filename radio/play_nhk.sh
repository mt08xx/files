#!/bin/bash
# sudo apt install -y mplayer rtmpdump swftools libxml2-utils

if [ $# -eq 1 ]; then
  channel=$1
  case $1 in
    r1) playpath='NetRadio_R1_flash@63346' ;;
    r2) playpath='NetRadio_R2_flash@63342' ;;
    fm) playpath='NetRadio_FM_flash@63343' ;;
    *) exit 1 ;;
  esac
else
  echo "usage : $0 channel_name"
  echo "         channel_name list"
  echo "           NHK Radio #1: r1"
  echo "           NHK Radio #2: r2"
  echo "           NHK-FM: fm"
  exit 1
fi

#
# parameter setting
#
playerurl="http://www3.nhk.or.jp/netradio/files/swf/rtmpe.swf"
rtmpurl="rtmpe://netradio-${channel}-flash.nhk.jp/live/${playpath}"
buffer=1000

#
# rtmpdump and mplayer
#
echo rtmpdump  \
         --rtmp "${rtmpurl}" \
         --swfVfy ${playerurl} \
         --live \
         --buffer ${buffer} \
         --flv - \
          mplayer -
