GO_EASY_ON_ME = 1
TARGET = iphone:latest:8.0
ARCHS = armv7 armv7s arm64

include theos/makefiles/common.mk

TWEAK_NAME = LockEmoji
LockEmoji_FILES = Tweak.xm
LockEmoji_FRAMEWORKS = UIKit
LockEmoji_PRIVATE_FRAMEWORKS = TextInput
#LockEmoji_LIBRARIES = inspectivec

include $(THEOS_MAKE_PATH)/tweak.mk
