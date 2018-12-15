JAVA_VERSION?=11
SYSTEM:=darwin

CC = gcc
LD = ld

CPPFLAGS += -DJAVA_VERSION=$(JAVA_VERSION) -isysroot $(SDK_ROOT) -arch x86_64
CXXFLAGS += -g
LDFLAGS += -L.
CXXFLAGS += -I$(JDK_ROOT)/include -I$(JDK_ROOT)/include/$(SYSTEM) -framework CoreFoundation -framework Foundation
LDLIBS += -lstdc++ -ljli_static -lz

all: clean
	$(CC) $(CPPFLAGS) $(CXXFLAGS) $(LDFLAGS) -o $(BUILD_DIR)/NextFractal NextFractal.mm $(LDLIBS)
	otool -L $(BUILD_DIR)/NextFractal

clean:
	rm -rf $(BUILD_DIR)/NextFractal *.dSYM
