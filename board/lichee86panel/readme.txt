Lichee RV Panel
===============

Lichee RV Panel is a docking station for the Nezha computing module, which
is is a low-cost RISC-V 64-bit based platform, powered by an
Allwinner D1 SoC. It features low resolution LCD touchscreen instead of an
HDMI cable.

How to build
============

$ make lichee86panel_defconfig
$ make

How to write the SD card
========================

Once the build process is finished you will have an image called "sdcard.img"
in the output/images/ directory.

Copy the bootable "sdcard.img" onto an SD card with "dd":

  $ sudo dd if=output/images/sdcard.img of=/dev/sdX

The Panel has a built in USB-to-UART connector which you can connect to for
initial console access. No wiring required. As this also powers the board
it may generate some garbage which halts the boot process. Simply hit
`<ENTER>` then type `boot` if this happens.
