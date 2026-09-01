export THEOS_PACKAGE_SCHEME = roothide
ARCHS = arm64
TARGET = iphone:clang:latest:16.5

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = DazyNotDisturbCCModule
DazyNotDisturbCCModule_FILES = DazyCCModule.m
DazyNotDisturbCCModule_INSTALL_PATH = /Library/ControlCenter/Bundles
DazyNotDisturbCCModule_FRAMEWORKS = UIKit
DazyNotDisturbCCModule_PRIVATE_FRAMEWORKS = ControlCenterUIKit
DazyNotDisturbCCModule_CFLAGS = -fobjc-arc
DazyNotDisturbCCModule_CODESIGN_FLAGS = -Sentitlements_empty.xml

include $(THEOS_MAKE_PATH)/bundle.mk
