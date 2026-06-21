TARGET := iphone:clang:latest:16.4
ARCHS := arm64 arm64e

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME := WebInspectEnabler
WebInspectEnabler_FILES := src/WebInspectEnabler.xm
WebInspectEnabler_FRAMEWORKS := WebKit
WebInspectEnabler_CFLAGS := -fobjc-arc

include $(THEOS_MAKE_PATH)/library.mk
