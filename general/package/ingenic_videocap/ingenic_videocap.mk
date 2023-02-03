INGENIC_VIDEOCAP_VERSION = v0.1.0
#INGENIC_VIDEOCAP_SITE = https://github.com/openmiko/ingenic_videocap.git
#INGENIC_VIDEOCAP_SITE_METHOD = git
INGENIC_VIDEOCAP_SITE_METHOD = local
INGENIC_VIDEOCAP_SITE = ../../ingenic_videocap_t31

INGENIC_VIDEOCAP_DEPENDENCIES = alsa-lib libpthread-stubs ingenic-osdrv-t31
INGENIC_VIDEOCAP_CONF_OPTS =

$(eval $(cmake-package))
