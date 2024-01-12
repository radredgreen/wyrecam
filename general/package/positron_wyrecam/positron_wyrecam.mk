
#POSITRON_WYRECAM_VERSION = 2f99c4622d44b79701efea43b24ecdc78092473f
#POSITRON_WYRECAM_SITE = https://github.com/radredgreen/t31-rtspd.git
#POSITRON_WYRECAM_LICENSE = BSD-3-Clause
#POSITRON_WYRECAM_SITE_METHOD = git

POSITRON_WYRECAM_SITE_METHOD = local
POSITRON_WYRECAM_SITE = ../../../positron

POSITRON_WYRECAM_CONF_OPTS =
POSITRON_WYRECAM_DEPENDENCIES = \
	jpeg-turbo \
	mbedtls-openipc \
	avahi

define POSITRON_WYRECAM_NEEDS_SYMLINKS
	ln -sf libuClibc-$(UCLIBC_VERSION).so $(TARGET_DIR)/lib/libdl.so.0
	ln -sf libuClibc-$(UCLIBC_VERSION).so $(TARGET_DIR)/lib/libm.so.0
	ln -sf libuClibc-$(UCLIBC_VERSION).so $(TARGET_DIR)/lib/libpthread.so.0
	ln -sf libuClibc-$(UCLIBC_VERSION).so $(TARGET_DIR)/lib/librt.so.0
endef

POSITRON_WYRECAM_POST_INSTALL_TARGET_HOOKS  += POSITRON_WYRECAM_NEEDS_SYMLINKS

$(eval $(cmake-package))

