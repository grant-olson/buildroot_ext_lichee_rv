# Buildroot Externals for Lichee RV Dock

This adds support for the RISC-V based Lichee RV products to buildroot
to allow you to easily build new systems.

## Building an image

1. Download this package and the buildroot source in peer directories:

    ```
    +-- src
      |- buildroot
      |- buildroot_ext_lichee_rv
    ````

2. Patch buildroot until I get the updates to the bootloader accepted upstream
    or figure out how to patch it via the extensions:

    ```
    grant@NUC:~/src$ cd buildroot
    grant@NUC:~/src/buildroot$ patch -d . -p1 < ../buildroot_ext_lichee_rv/0001-fix-sun20i-d1-spl-in-buildroot.patch 
    patching file boot/sun20i-d1-spl/sun20i-d1-spl.hash
    patching file boot/sun20i-d1-spl/sun20i-d1-spl.mk
    grant@NUC:~/src/buildroot$ git diff
    diff --git a/boot/sun20i-d1-spl/sun20i-d1-spl.hash b/boot/sun20i-d1-spl/sun20i-d1-spl.hash
    deleted file mode 100644
    index 6ca60e5278..0000000000
    --- a/boot/sun20i-d1-spl/sun20i-d1-spl.hash
    +++ /dev/null
    @@ -1,2 +0,0 @@
    -# Locally computed
    -sha256  69063601239a7254fb72e486b138d88a6f2b5c645b24cdfe9792123f975d4a8f  sun20i-d1-spl-771192d0b3737798d7feca87263c8fa74a449787.tar.gz
    diff --git a/boot/sun20i-d1-spl/sun20i-d1-spl.mk b/boot/sun20i-d1-spl/sun20i-d1-spl.mk
    index 2462ce2322..1f1cd99b2d 100644
    --- a/boot/sun20i-d1-spl/sun20i-d1-spl.mk
    +++ b/boot/sun20i-d1-spl/sun20i-d1-spl.mk
    @@ -5,7 +5,7 @@
     ################################################################################
     
     # Commit on the 'mainline' branch
    -SUN20I_D1_SPL_VERSION = 771192d0b3737798d7feca87263c8fa74a449787
    +SUN20I_D1_SPL_VERSION = 525883d3721f4c4d78b498e780b44e85d0676abf
     SUN20I_D1_SPL_SITE = $(call github,smaeul,sun20i_d1_spl,$(SUN20I_D1_SPL_VERSION))
     SUN20I_D1_SPL_INSTALL_TARGET = NO
     SUN20I_D1_SPL_INSTALL_IMAGES = YES
    grant@NUC:~/src/buildroot$ 

    ```
    
3. Enter the **buildroot** directory, enable the external package, and
    grab a lichee rv configuration.

    ```
    grant@NUC:~/src/buildroot2$ make BR2_EXTERNAL=~/src/buildroot_ext_lichee_rv licheedock_defconfig
    ```

4. You will probably want to do some minimal configuration. For
    example adding **dropbear** for ssh access and **nano** so you don't
    need to use `vi` to edit files.

    ```make menuconfig```

5. Build the system.

    ```make```

6. Grab the image in `output/images/sdcard.img` and deploy it.

## Disabling external package

1. If you want to remove the external package run `make BR2_EXTERNAL= menuconfig`

## Connecting with Serial Console

You will want to have access to a serial console for initial
configuration. Get a cheap UART adapter that support 3.3 Volt logic levels. I usually buy one that has a jumper to switch between 5 and 3.3 Volts.

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