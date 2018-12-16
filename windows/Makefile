SYSTEM:=win32

CC = /usr/bin/x86_64-w64-mingw32-gcc
LD = /usr/bin/x86_64-w64-mingw32-ld
RC = /usr/bin/x86_64-w64-mingw32-windres
OBJDUMP = /usr/bin/x86_64-w64-mingw32-objdump

CCFLAGS += -std=c++11 -g -I$(JDK_ROOT)/include -I$(JDK_ROOT)/include/$(SYSTEM)
LDFLAGS += -Wl,-static
LDLIBS += -lstdc++

all: clean
	$(RC) NextFractal.rc $(BUILD_DIR)/resources.o
	$(CC) $(CCFLAGS) $(LDFLAGS) -o $(BUILD_DIR)/NextFractal.exe NextFractal.cpp $(BUILD_DIR)/resources.o $(LDLIBS)
	$(OBJDUMP) -p $(BUILD_DIR)/NextFractal.exe | grep 'DLL Name'

clean:
	rm -rf $(BUILD_DIR)/NextFractal
