## RTC Module

```
git clone --depth 1 -b linux4.4-rk3288 https://github.com/TinkerBoard/debian_kernel.git
#commit 7c5c2657606b034217a12ddd44d39034c8e8cf6d
cd debian_kernel
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- miniarm-rk3288_defconfig
echo "CONFIG_RTC_DRV_DS1307=m" >> .config
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- modules
cp ./drivers/rtc/rtc-ds1307.ds ~
```
