################################################################################
#
# ingenic_samples
#
################################################################################

INGENIC_SAMPLES_VERSION = v0.1.0
#INGENIC_SAMPLES_SOURCE = ingenic-samples.tar.gz
INGENIC_SAMPLES_SITE = ../../Ingenic-SDK-T31-1.1.1-20200508/samples
#INGENIC_SAMPLES_SITE = ../../openmiko/custompackages/package/ingenic_samples
INGENIC_SAMPLES_DEPENDENCIES =
INGENIC_SAMPLES_CONF_OPTS =
INGENIC_SAMPLES_SITE_METHOD = local

define INGENIC_SAMPLES_BUILD_CMDS
        $(MAKE) -C $(@D)/libimp-samples TARGET_CROSS="$(TARGET_CROSS)" CXX="$(TARGET_CXX)" LD="$(TARGET_LD)" sample-Encoder-video
endef

define INGENIC_SAMPLES_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/libimp-samples/sample-Encoder-video $(TARGET_DIR)/usr/sbin

# 	$(INSTALL) -D -m 0755 $(@D)/libimp-samples/sample-ISP-flip $(TARGET_DIR)/usr/sbin
# 	$(INSTALL) -D -m 0755 $(@D)/libimp-samples/sample-Setfps $(TARGET_DIR)/usr/sbin
# 	$(INSTALL) -D -m 0755 $(@D)/libimp-samples/sample-Decoder-jpeg $(TARGET_DIR)/usr/sbin
# 	$(INSTALL) -D -m 0755 $(@D)/libimp-samples/sample-Change-Resolution $(TARGET_DIR)/usr/sbin
# 	$(INSTALL) -D -m 0755 $(@D)/libimp-samples/sample-OSD $(TARGET_DIR)/usr/sbin
# 	$(INSTALL) -D -m 0755 $(@D)/libimp-samples/sample-Snap-Raw $(TARGET_DIR)/usr/sbin
# 	$(INSTALL) -D -m 0755 $(@D)/libimp-samples/sample-Encoder-h264-IVS-move $(TARGET_DIR)/usr/sbin
# 	$(INSTALL) -D -m 0755 $(@D)/libimp-samples/sample-Encoder-jpeg $(TARGET_DIR)/usr/sbin
# 	$(INSTALL) -D -m 0755 $(@D)/libimp-samples/sample-Encoder-h264-jpeg $(TARGET_DIR)/usr/sbin
# 	$(INSTALL) -D -m 0755 $(@D)/libimp-samples/sample-Audio $(TARGET_DIR)/usr/sbin

endef

$(eval $(generic-package))



