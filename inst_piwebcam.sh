#!/bin/bash
#
# http://qiita/com/mt08/f869cddee89ca2ea6323
#
# apt-cacher-ng ?
# export http_proxy="http://apt-cache-server.local:3142"
#
sudo apt update && sudo apt-get install -y git \
&& cd ${HOME} \
&& git clone https://github.com/climberhunt/uvc-gadget.git \
&& cd uvc-gadget \
&& make

sudo sed -i -e 's/rootwait$/rootwait modules-load=dwc2,libcomposite/' /boot/cmdline.txt
grep 'dtoverlay=dwc2' /boot/config.txt || sudo sed -i -e '/\[all\]/a dtoverlay=dwc2' /boot/config.txt
sudo raspi-config nonint do_camera 0
sudo raspi-config nonint do_memory_split 256

cat << 'EOF' | sudo tee /etc/systemd/system/piwebcam.service
[Unit]
Description=Start pi webcam service

[Service]
ExecStart=/home/pi/uvc-gadget/piwebcam
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=piwebcam
User=pi
Group=pi
WorkingDirectory=/home/pi/uvc-gadget

[Install]
WantedBy=basic.target
EOF

sudo ln -s /lib/systemd/system/getty@.service  /etc/systemd/system/getty.target.wants/getty@ttyGS0.service
sudo systemctl enable piwebcam.service

#
echo Done
