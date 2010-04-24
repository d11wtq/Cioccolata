include $(GNUSTEP_MAKEFILES)/common.make

CIOCCOLATA_ROOT_DIR = $(abspath .)

GNUSTEP_BUILD_DIR = ${CIOCCOLATA_ROOT_DIR}/build/GNUStep

PACKAGE_NAME = Cioccolata
FRAMEWORK_NAME = Cioccolata

Cioccolata_OBJC_FILES = CTFastCGIAcceptLoop.m CTFastCGIAcceptWorkerThread.m CTFastCGIAcceptWorkerOperation.m
Cioccolata_HEADER_FILES = CTFastCGIAcceptLoop.h NSThread+GNUStep.h Cioccolata.h
Cioccolata_OBJC_PRECOMPILED_HEADERS = Cioccolata_Prefix.h
ADDITIONAL_OBJCFLAGS += -include Cioccolata_Prefix.h -Winvalid-pch -std=gnu99

include $(GNUSTEP_MAKEFILES)/framework.make
