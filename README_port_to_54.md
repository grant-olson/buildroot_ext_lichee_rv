# Allwinner 5.4 Builds

Make the following changes

## Mock board fixes

Add file to disable vectors so we don't need hacked allwinner
sdk. This is used everywhere so make a fake board `allwinner_54`.

`board/allwinner_54/linux-disable-vector.config`  should be:


```
# This is in allwinners SDK but not a freshly built one
# Lets not rely on Allwinner.
CONFIG_VECTOR=n
```

## XXX_defconfig Fixes

Set version for linux headers to 5.4 replacing this setting:

```
BR2_PACKAGE_HOST_LINUX_HEADERS_CUSTOM_5_4=y
```

Replace Linux Kernel settings with to point to cuu's version
of allwinner 5.4:

```
BR2_LINUX_KERNEL=y
BR2_LINUX_KERNEL_CUSTOM_TARBALL=y
BR2_LINUX_KERNEL_CUSTOM_TARBALL_LOCATION="$(call github,cuu,last_linux-5.4,a93ac38b8afb526c534003619ca9f0a7a0be0e06)/last_linux-5.4-a93ac38b8afb526c534003619ca9f0a7a0be0e06.tar.gz"
BR2_LINUX_KERNEL_DEFCONFIG="sun20iw1p1_d1"
BR2_LINUX_KERNEL_DTS_SUPPORT=y
BR2_LINUX_KERNEL_INTREE_DTS_NAME="sunxi/board"
BR2_LINUX_KERNEL_INSTALL_TARGET=y
BR2_LINUX_KERNEL_CONFIG_FRAGMENT_FILES="$(BR2_EXTERNAL_LICHEERV_PATH)/board/allwinner_54/linux-disable-vector.config"
```

## Real board fixes

The 5.18 kernel gets its device tree from U-Boot. We do not want this
on 5.4 it should load the kernel's device tree. To do this we switch
from using `boot.scr` to tell U-Boot what to do, and use
`extlinux/extlinux.conf` instead.

For each board:

Remove files `overlay/boot.scr` and `overlay/boot.scr.txt`

Add file `overlay/extlinux/extlinux.conf` with this contents:

```
label linux
  kernel /boot/Image
  devicetree /boot/board.dtb
  append earlyprintk=sunxi-uart,0x02500000 clk_ignore_unused initcall_debug=0 console=ttyS0,115200n8 console=tty0 loglevel=8 root=/dev/mmcblk0p1 ro rootwait cma=8M video=LVDS-1:e fbcon=map:0
```