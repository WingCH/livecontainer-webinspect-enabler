TARGET := iphone:clang:latest:16.4
ARCHS := arm64 arm64e

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME := WebInspectLite
WebInspectLite_FILES := src/WebInspectLite.xm
WebInspectLite_FRAMEWORKS := WebKit
WebInspectLite_CFLAGS := -fobjc-arc

include $(THEOS_MAKE_PATH)/library.mk
