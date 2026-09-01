export THEOS_PACKAGE_SCHEME = roothide
ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:16.5

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = DazyNotDisturbPrefs
DazyNotDisturbPrefs_FILES = DNBRootListController.m DNBAppListController.m
DazyNotDisturbPrefs_INSTALL_PATH = /Library/PreferenceBundles
DazyNotDisturbPrefs_FRAMEWORKS = UIKit Foundation
DazyNotDisturbPrefs_PRIVATE_FRAMEWORKS = Preferences
DazyNotDisturbPrefs_RESOURCE_FILES = Info.plist Root.plist icon.png TargetApps.plist
DazyNotDisturbPrefs_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

# Stage entry plist for PreferenceLoader (bug 3 fix)
internal-stage::
	@mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences
	@cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/DazyNotDisturb.plist
