SYSTEM:=linux

CC = gcc
LD = ld

CCFLAGS += -no-pie -std=c++11 -g -I$(JDK_ROOT)/include -I$(JDK_ROOT)/include/$(SYSTEM) $(shell pkg-config --cflags glib-2.0) $(shell pkg-config --cflags gtk+-3.0)
LDFLAGS +=
LDLIBS += -lstdc++ -ldl $(shell pkg-config --libs --cflags gtk+-3.0)

all: clean
	$(CC) $(CCFLAGS) $(LDFLAGS) -o $(BUILD_DIR)/NextFractal NextFractal.cpp $(LDLIBS)
	readelf -d $(BUILD_DIR)/NextFractal | grep 'NEEDED'

clean:
	rm -rf $(BUILD_DIR)/NextFractal
