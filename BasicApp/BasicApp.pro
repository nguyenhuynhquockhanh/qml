QT += quick

CONFIG += c++11

# The following define makes your compiler emit warnings if you use
# any Qt feature that has been marked deprecated (the exact warnings
# depend on your compiler). Refer to the documentation for the
# deprecated API to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

# You can also make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
        main.cpp

RESOURCES += qml.qrc \
    images.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
#qnx: target.path = /tmp/$${TARGET}/bin
#else: unix:!android: target.path = /opt/$${TARGET}/bin
#!isEmpty(target.path): INSTALLS += target
target.path = /home/ras/BasicApp/bin
INSTALLS += target

# Cấu hình Sysroot và Cross-Compiler chuẩn cho Pi 4 (aarch64)
QMAKE_SYSROOT = /home/khanhne/rpi-qt/sysroot
QMAKE_CC = /home/khanhne/rpi-qt/tools/cross-pi-gcc/bin/aarch64-linux-gnu-gcc
QMAKE_CXX = /home/khanhne/rpi-qt/tools/cross-pi-gcc/bin/aarch64-linux-gnu-g++
QMAKE_LINK = /home/khanhne/rpi-qt/tools/cross-pi-gcc/bin/aarch64-linux-gnu-g++

# 1. Chỉ định thư mục tìm thư viện chính
QMAKE_LIBDIR += $$QMAKE_SYSROOT/usr/lib/aarch64-linux-gnu
QMAKE_LIBDIR += $$QMAKE_SYSROOT/lib/aarch64-linux-gnu
QMAKE_LIBDIR += /home/khanhne/rpi-qt/qt5.15/lib

# 2. Chỉ định thư mục tìm thư viện phụ thuộc ngầm
QMAKE_LFLAGS += --sysroot=$$QMAKE_SYSROOT
QMAKE_LFLAGS += -Wl,-rpath-link,$$QMAKE_SYSROOT/lib/aarch64-linux-gnu
QMAKE_LFLAGS += -Wl,-rpath-link,$$QMAKE_SYSROOT/usr/lib/aarch64-linux-gnu
QMAKE_LFLAGS += -Wl,-rpath-link,$$QMAKE_SYSROOT/usr/lib/aarch64-linux-gnu/mesa
QMAKE_LFLAGS += -Wl,-rpath-link,/home/khanhne/rpi-qt/qt5.15/lib

QMAKE_CFLAGS += --sysroot=$$QMAKE_SYSROOT
QMAKE_CXXFLAGS += --sysroot=$$QMAKE_SYSROOT
