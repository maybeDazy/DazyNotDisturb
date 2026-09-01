export THEOS_PACKAGE_SCHEME = roothide
ARCHS = arm64 arm64e
TARGET = iphone:clang:16.0:16.5

include $(THEOS)/makefiles/common.mk

TOOL_NAME = dndctl
dndctl_FILES = dndctl.m
dndctl_CFLAGS = -fobjc-arc
dndctl_FRAMEWORKS = Foundation CoreFoundation
dndctl_INSTALL_PATH = /usr/bin

include $(THEOS_MAKE_PATH)/tool.mk
