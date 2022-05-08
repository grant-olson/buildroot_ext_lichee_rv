#
# rtl8723ds
#

RTL8723DS_VERSION = 76146e85847beb2427b1d4958fa275822f2b04ab
RTL8723DS_SITE = $(call github,lwfinger,rtl8723ds,$(RTL8723DS_VERSION))
RTL8723DS_LICENSE = GPL-2.0

RTL8723DS_MODULE_MAKE_OPTS = \
	CONFIG_RTL8723DS=m \
	KVER=$(LINUX_VERSION_PROBED) \
	KSRC=$(LINUX_DIR)

define RTL8723DS_INSTALL_INIT_SYSV
	$(INSTALL) -m 755 -D package/rtl8723ds/S30modprobe $(TARGET_DIR)/etc/init.d/S30modprobe
	echo 8723ds >> $(TARGET_DIR)/etc/modules
endef



$(eval $(kernel-module))
$(eval $(generic-package))
