SYSTEM:=darwin

CC = gcc
LD = ld

CCFLAGS += -isysroot $(SDK_ROOT) -arch x86_64 -g -I$(JDK_ROOT)/include -I$(JDK_ROOT)/include/$(SYSTEM) -framework CoreFoundation -framework Foundation
LDFLAGS += -L. 
LDLIBS += -lstdc++ -ljli_static -lz

all: clean
	$(CC) $(CCFLAGS) $(LDFLAGS) -o $(BUILD_DIR)/NextFractal NextFractal.mm $(LDLIBS)
	otool -L $(BUILD_DIR)/NextFractal

clean:
	rm -rf $(BUILD_DIR)/NextFractal *.dSYM
