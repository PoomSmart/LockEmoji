DEBUG = 0
SIMULATOR = 1

ifeq ($(SIMULATOR),1)
	TARGET = simulator:clang:latest:8.0
	ARCHS = x86_64 i386
else
	TARGET = iphone:clang:latest:8.0
	ARCHS = armv7 arm64
endif

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = LockEmoji
LockEmoji_FILES = Tweak.xm
LockEmoji_FRAMEWORKS = UIKit
LockEmoji_PRIVATE_FRAMEWORKS = TextInput
LockEmoji_USE_SUBSTRATE = 1

include $(THEOS_MAKE_PATH)/tweak.mk

all::
ifeq ($(SIMULATOR),1)
	@cp -v $(PWD)/.theos/$(THEOS_OBJ_DIR_NAME)/*.dylib /opt/simject
	@cp -v $(PWD)/*.plist /opt/simject
endif