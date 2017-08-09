# rk3288-uboot image

- idbloader.img


## Example
- dd if=./idbloader.img of=./2017-07-05-raspbian-jessie.img seek=64 conv=notrunc
- dd if=./idbloader.img of=/dev/sda seek=64 conv=notrunc

