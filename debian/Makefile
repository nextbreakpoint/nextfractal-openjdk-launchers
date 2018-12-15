JAVA_VERSION?=11
SYSTEM:=linux

CC = gcc
LD = ld

CPPFLAGS += -DJAVA_VERSION=$(JAVA_VERSION) -std=c++11
CXXFLAGS += -g
LDFLAGS +=
CXXFLAGS += -I$(JDK_ROOT)/include -I$(JDK_ROOT)/include/$(SYSTEM) $(shell pkg-config --cflags glib-2.0) $(shell pkg-config --cflags gtk+-3.0)
LDLIBS += -lstdc++ -ldl

all: clean
	$(CC) $(CPPFLAGS) $(CXXFLAGS) $(LDFLAGS) -o $(BUILD_DIR)/NextFractal NextFractal.cpp $(LDLIBS) $(shell pkg-config --libs --cflags gtk+-3.0)
	readelf -d $(BUILD_DIR)/NextFractal | grep 'NEEDED'

clean:
	rm -rf $(BUILD_DIR)/NextFractal
