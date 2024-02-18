
#POSITRON_WYRECAM_LICENSE = GPL v3

#MAVLINK_ROUTER_SITE_METHOD = local
#MAVLINK_ROUTER_SITE = ../../mavlink-router-cmake

MAVLINK_ROUTER_VERSION = 8c4c670cdb2c1761bb538bc34cbf8bbb942ceada
MAVLINK_ROUTER_SITE_METHOD = git
MAVLINK_ROUTER_SITE = https://github.com/radredgreen/mavlink-router-cmake.git
#MAVLINK_ROUTER_GIT_SUBMODULES = YES


$(eval $(cmake-package))

