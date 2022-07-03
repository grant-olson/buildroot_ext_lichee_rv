# Buildroot Externals for Allwinner D1 boards

This adds support for the RISC-V boards based on the Allwinner D1 SoC.

Buildroot has support for the main Nezha board, but it does not have
built in support for the additional hardware on these boards. This
package attempts to add support for all hardware.

## Board Status

* Lichee RV Dock - `licheedock_defconfig`
    * Well supported.
    * Serial Console access.
* Lichee 86 Panel - `lichee86panel_defconfig`
    * Networking and LCD screen don't work.
    * Access shell via USB-UART interface.
* Clockwork Pi DevTerm - `clockworkpi_defconfig`
    * Can be used with HDMI monitor and/or external USB keyboard.
    * Networking and LCD screen don't work.
    * Hidden UART interface shows logs but is non-interactive.
* Dongshan Pi - `dongshanpi_defconfig`
    * External monitor fires up.
    * Still no USB so no keyboard.
    * DEBUG interface provides console. NOTE: this is on /dev/ttyACM0 instead of /dev/ttyUSB0

## Kernel Notes

We're running 5.18 rc 4 on the main branch.

There is a branch allwinner_5.4 which compiles some of the interfaces
with the version of kernel that these products use. If it provides better hardware
support in the long run it will be moved back to mainline.

So far using the 5.4 kernel hasn't made it easier to find devices.

The 5.18 version uses `boot.scr` to configure the kernel so it can get
the live DTC created by U-Boot. I beleive this is done so that we can get
dynamic things like memory size.

The 5.4 version uses `extlinux/extlinux.conf`

## Building an image

1. Download this package and the buildroot source in peer directories:

    ```
    +-- src
      |- buildroot
      |- buildroot_ext_lichee_rv
    ````

2. If you are running the latest LTS (2022.02) you must patch buildroot to
    get the correct bootloader. This is not required for 2022.05+. Assuming
    you're using the directory structure above:

    ```
    patch -d . -p1 < ../buildroot_ext_lichee_rv/0001-fix-sun20i-d1-spl-in-buildroot.patch 
    ```
    
3. Enter the **buildroot** directory, enable the external package, and
    grab a configuration.

    ```
    make BR2_EXTERNAL=~/src/buildroot_ext_lichee_rv licheedock_defconfig
    ```

    See the config names for each board listed above.

4. You will probably want to do some minimal configuration. For
    example adding **dropbear** for ssh access and **nano** so you don't
    need to use `vi` to edit files.

    ```make menuconfig```

5. Build the system.

    ```make```

6. Grab the image in `output/images/sdcard.img` and deploy it.

## Disabling external package

1. If you want to remove the external package run `make BR2_EXTERNAL= menuconfig`

## Lichee Dock Serial Console

If you're developing you'll want this in case you lose screen or
keyboard. Get a cheap UART adapter that support 3.3 Volt logic
levels. I usually buy one that has a jumper to switch between 5 and
3.3 Volts.

```
    <USB A CONNECTOR>

                  +------+
		  | .  . |
		  | .  . |
		  | .  . | - GROUND
		  | .  . | - TX
		  | .  . | - RX
		  | .  . |
		  | .  . |
		  | .  . |
		  | .  . |
		  | .  . |
		  | .  . |
		  | .  . |
		  | .  . |
		  | .  . |
		  | .  . |
		  | .  . |
		  | .  . |
		  | .  . |
		  | .  . |
		  | .  . |
                  +------+
		  

    <HDMI CONNECTOR>
```

Remember that the TX on the board should be connected to the RX on the
UART adapter, and the RX on the board should connect to the TX on the
UART adapter!

## Setting up wifi credentials

1. Connect to serial console

2. Generate a wpa configuration:

    ```
    # wpa_passphrase "MyNetwork" foobar88
    network={
            ssid="MyNetwork"
            #psk="foobar88"
            psk=67224fb26d73f404f3c12d2576bc9cb220d068318f9a44b97ad548f15d71058c
    }

3. Replace the network section of `/etc/wpa_supplicant.conf` on the Lichee RV.

    ```
    # cat /etc/wpa_supplicant.conf 
    ctrl_interface=/var/run/wpa_supplicant
    ap_scan=1

    network={
            ssid="MyNetwork"
            #psk="foobar88"
            psk=67224fb26d73f404f3c12d2576bc9cb220d068318f9a44b97ad548f15d71058c
    }
    ```

4. Reboot: `/sbin/reboot`

5. get the ip:

    ```
    # ifconfig
    lo        Link encap:Local Loopback  
              inet addr:127.0.0.1  Mask:255.0.0.0
              inet6 addr: ::1/128 Scope:Host
              UP LOOPBACK RUNNING  MTU:65536  Metric:1
              RX packets:0 errors:0 dropped:0 overruns:0 frame:0
              TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
              collisions:0 txqueuelen:1000 
              RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

    wlan0     Link encap:Ethernet  HWaddr 2C:05:47:35:8D:E1  
              inet addr:192.168.1.109  Bcast:192.168.1.255  Mask:255.255.255.0
              inet6 addr: fe80::2e05:47ff:fe35:8de1/64 Scope:Link
              UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
              RX packets:28 errors:0 dropped:4 overruns:0 frame:0
              TX packets:12 errors:0 dropped:0 overruns:0 carrier:0
              collisions:0 txqueuelen:1000 
              RX bytes:5422 (5.2 KiB)  TX bytes:1904 (1.8 KiB)


    ```