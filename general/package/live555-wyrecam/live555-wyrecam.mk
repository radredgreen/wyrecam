################################################################################
#
# live555
#
################################################################################

LIVE555_WYRECAM_VERSION = 2021.05.03
LIVE555_WYRECAM_SOURCE = live.$(LIVE555_WYRECAM_VERSION).tar.gz
#LIVE555_WYRECAM_SITE = http://www.live555.com/liveMedia/public
LIVE555_WYRECAM_SITE = https://download.videolan.org/contrib/live555
# There is a COPYING file with the GPL-3.0 license text, but none of
# the source files appear to be released under GPL-3.0, and the
# project web site says it's licensed under the LGPL:
# http://live555.com/liveMedia/faq.html#copyright-and-license
LIVE555_WYRECAM_LICENSE = LGPL-3.0+
LIVE555_WYRECAM_LICENSE_FILES = COPYING.LESSER
LIVE555_WYRECAM_CPE_ID_VENDOR = live555-wyrecam
LIVE555_WYRECAM_CPE_ID_PRODUCT = streaming_media
LIVE555_WYRECAM_INSTALL_STAGING = YES

LIVE555_WYRECAM_CFLAGS = $(TARGET_CFLAGS)

ifeq ($(BR2_STATIC_LIBS),y)
LIVE555_WYRECAM_CONFIG_TARGET = linux
LIVE555_WYRECAM_LIBRARY_LINK = $(TARGET_AR) cr
else
LIVE555_WYRECAM_CONFIG_TARGET = linux-with-shared-libraries
LIVE555_WYRECAM_LIBRARY_LINK = $(TARGET_CC) -o
LIVE555_WYRECAM_CFLAGS += -fPIC
endif

ifeq ($(BR2_PACKAGE_OPENSSL),y)
LIVE555_WYRECAM_DEPENDENCIES += host-pkgconf openssl
LIVE555_WYRECAM_CONSOLE_LIBS = `$(PKG_CONFIG_HOST_BINARY) --libs openssl`
# passed to ar for static linking, which gets confused by -L<dir>
ifneq ($(BR2_STATIC_LIBS),y)
LIVE555_WYRECAM_LIVEMEDIA_LIBS = $(LIVE555_WYRECAM_CONSOLE_LIBS)
endif
else
LIVE555_WYRECAM_CFLAGS += -DNO_OPENSSL
endif

ifndef ($(BR2_ENABLE_LOCALE),y)
LIVE555_WYRECAM_CFLAGS += -DLOCALE_NOT_USED
endif

define LIVE555_WYRECAM_CONFIGURE_CMDS
	echo 'COMPILE_OPTS = $$(INCLUDES) -I. -DSOCKLEN_T=socklen_t $(LIVE555_WYRECAM_CFLAGS)' >> $(@D)/config.$(LIVE555_WYRECAM_CONFIG_TARGET)
	echo 'C_COMPILER = $(TARGET_CC)' >> $(@D)/config.$(LIVE555_WYRECAM_CONFIG_TARGET)
	echo 'CPLUSPLUS_COMPILER = $(TARGET_CXX)' >> $(@D)/config.$(LIVE555_WYRECAM_CONFIG_TARGET)

	echo 'LINK = $(TARGET_CXX) -o' >> $(@D)/config.$(LIVE555_WYRECAM_CONFIG_TARGET)
	echo 'LINK_OPTS = -L. $(TARGET_LDFLAGS)' >> $(@D)/config.$(LIVE555_WYRECAM_CONFIG_TARGET)
	echo 'PREFIX = /usr' >> $(@D)/config.$(LIVE555_WYRECAM_CONFIG_TARGET)
	# Must have a whitespace at the end of LIBRARY_LINK, otherwise static link
	# fails
	echo 'LIBRARY_LINK = $(LIVE555_WYRECAM_LIBRARY_LINK) ' >> $(@D)/config.$(LIVE555_WYRECAM_CONFIG_TARGET)
	echo 'LIBS_FOR_CONSOLE_APPLICATION = $(LIVE555_WYRECAM_CONSOLE_LIBS)' >> $(@D)/config.$(LIVE555_WYRECAM_CONFIG_TARGET)
	echo 'LIBS_FOR_LIVEMEDIA_LIB = $(LIVE555_WYRECAM_LIVEMEDIA_LIBS)' >> $(@D)/config.$(LIVE555_WYRECAM_CONFIG_TARGET)
	(cd $(@D); ./genMakefiles $(LIVE555_WYRECAM_CONFIG_TARGET))
endef

define LIVE555_WYRECAM_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) all
endef

define LIVE555_WYRECAM_INSTALL_STAGING_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) DESTDIR=$(STAGING_DIR) -C $(@D) install
endef

define LIVE555_WYRECAM_INSTALL_TARGET_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) DESTDIR=$(TARGET_DIR) PREFIX=/usr -C $(@D) install
endef

$(eval $(generic-package))
