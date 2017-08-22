#!/bin/bash
# sudo apt install -y mplayer rtmpdump swftools libxml2-utils

playerurl=http://radiko.jp/apps/js/flash/myplayer-release.swf
playerfile="/tmp/player.swf"

if [ $# -le 0 ]; then echo "usage : $0 channel_name"; exit 1; fi
if [ $# -eq 2 ]; then rm -f ${playerfile}; fi

channel=$1

#
echo "Getting player.swf ..."
#
if [ ! -f $playerfile ]; then
  wget -q -O $playerfile $playerurl
  if [ $? -ne 0 ]; then echo "failed get player"; exit 1; fi
fi

#
echo "Accessing auth1_fms..."
#
auth1_fms=`wget -q \
     --header="pragma: no-cache" \
     --header="X-Radiko-App: pc_ts" \
     --header="X-Radiko-App-Version: 4.0.0" \
     --header="X-Radiko-User: test-stream" \
     --header="X-Radiko-Device: pc" \
     --post-data='\r\n' \
     --no-check-certificate \
     --save-headers \
     https://radiko.jp/v2/api/auth1_fms \
     -O -`
if [ $? -ne 0 -o ! "${auth1_fms}" ]; then echo "failed auth1 process" 1>&2 ; exit 1; fi

#
echo "Getting partial key..."
#
authtoken=`echo ${auth1_fms} | perl -ne 'print $1 if(/x-radiko-authtoken: ([\w-]+)/i)'`
offset=`echo ${auth1_fms} | perl -ne 'print $1 if(/x-radiko-keyoffset: (\d+)/i)'`
length=`echo ${auth1_fms} | perl -ne 'print $1 if(/x-radiko-keylength: (\d+)/i)'`
partialkey=`wget -q -O - ${playerurl} 2>/dev/null | \
            swfextract -b 12 /dev/stdin -o /dev/stdout | \
            dd bs=1 skip=${offset} count=${length} 2> /dev/null | \
            base64`
if [ $? -ne 0 -o ! "${partialkey}" ]; then echo "failed auth1 process" 1>&2; exit 1; fi

#
echo "Accessing auth2_fms..."
#
auth2_fms=`wget -q \
     --header="pragma: no-cache" \
     --header="X-Radiko-App: pc_ts" \
     --header="X-Radiko-App-Version: 4.0.0" \
     --header="X-Radiko-User: test-stream" \
     --header="X-Radiko-Device: pc" \
     --header="X-Radiko-Authtoken: ${authtoken}" \
     --header="X-Radiko-Partialkey: ${partialkey}" \
     --post-data='\r\n' \
     --no-check-certificate \
     https://radiko.jp/v2/api/auth2_fms \
     -O -`

if [ $? -ne 0 -o ! "${auth2_fms}" ]; then echo "failed auth2 process" 1>&2; exit 1; fi

echo "Authentication success :-)"
echo ${auth2_fms}
areaid=`echo ${auth2_fms} | perl -ne 'print $1 if(/^([^,]+),/i)'`
echo "areaid: $areaid"
echo "${playerurl}" "${authtoken}"

#
# Getting stream-url
#

rm -f ${channel}.xml
wget -q "http://radiko.jp/v2/station/stream/${channel}.xml"
stream_url=`echo "cat /url/item[1]/text()" | xmllint --shell ${channel}.xml | tail -2 | head -1`
url_parts=(`echo ${stream_url} | perl -pe 's!^(.*)://(.*?)/(.*)/(.*?)$/!$1://$2 $3 $4!'`)
rm -f ${channel}.xml

echo ${url_parts[0]}
echo ${url_parts[1]}
echo ${url_parts[2]}
echo $playerurl
echo $authtoken


rtmpdump -v \
    -r ${url_parts[0]} \
    --app ${url_parts[1]} \
    --playpath ${url_parts[2]} \
    -W $playerurl \
    -C S:"" -C S:"" -C S:"" -C S:$authtoken \
    --live \
    -- buffer 1000 \
    | mplayer -
