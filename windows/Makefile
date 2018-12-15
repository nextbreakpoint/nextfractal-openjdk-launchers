JAVA_VERSION?=11
SYSTEM:=win32

CC = /usr/bin/x86_64-w64-mingw32-gcc
LD = /usr/bin/x86_64-w64-mingw32-ld
RC = /usr/bin/x86_64-w64-mingw32-windres
OBJDUMP = /usr/bin/x86_64-w64-mingw32-objdump

CPPFLAGS += -DJAVA_VERSION=$(JAVA_VERSION) -std=c++11 -Os
CXXFLAGS += -g
LDFLAGS += -L/usr/x86_64-w64-mingw32/lib -Wl,-static
CXXFLAGS += -I/usr/x86_64-w64-mingw32/include -I$(JDK_ROOT)/include -I$(JDK_ROOT)/include/$(SYSTEM)
LDLIBS += -lstdc++

all: clean
	$(RC) NextFractal.rc $(BUILD_DIR)/resources.o
	$(CC) $(CPPFLAGS) $(CXXFLAGS) $(LDFLAGS) -o $(BUILD_DIR)/NextFractal.exe NextFractal.cpp $(BUILD_DIR)/resources.o $(LDLIBS)
	$(OBJDUMP) -p $(BUILD_DIR)/NextFractal.exe | grep 'DLL Name'

clean:
	rm -rf $(BUILD_DIR)/NextFractal
