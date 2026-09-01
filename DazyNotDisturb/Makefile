export THEOS_PACKAGE_SCHEME = roothide
ARCHS = arm64
TARGET = iphone:clang:latest:16.5
INSTALL_TARGET_PROCESSES = SpringBoard Preferences

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = DazyNotDisturb
DazyNotDisturb_FILES = Tweak.x TelegramSender.m
DazyNotDisturb_FRAMEWORKS = UIKit Foundation
DazyNotDisturb_LIBRARIES = roothide
DazyNotDisturb_CFLAGS = -fobjc-arc
DazyNotDisturb_LDFLAGS = -F/usr/lib -framework BulletinBoard
DazyNotDisturb_CODESIGN_FLAGS = -Sentitlements_empty.xml

PACKAGE_SCRIPTS = DEBIAN

include $(THEOS_MAKE_PATH)/tweak.mk

# Stage DEBIAN scripts for packaging
after-stage::
	@mkdir -p $(THEOS_STAGING_DIR)/DEBIAN
	@cp DEBIAN/postinst $(THEOS_STAGING_DIR)/DEBIAN/postinst
	@cp DEBIAN/postrm $(THEOS_STAGING_DIR)/DEBIAN/postrm
	@chmod 755 $(THEOS_STAGING_DIR)/DEBIAN/postinst $(THEOS_STAGING_DIR)/DEBIAN/postrm

after-install::
	install.exec "killall -9 SpringBoard"

SUBPROJECTS += DazyNotDisturbPrefs tools CCModule
include $(THEOS_MAKE_PATH)/aggregate.mk
