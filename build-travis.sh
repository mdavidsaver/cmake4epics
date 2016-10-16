#!/bin/sh
set -e -x

[ "$BASEURL" ] || BASEURL=https://github.com/epics-base/epics-base
[ "$BASEBRANCH" ] || BASEBRANCH=3.14
# TARGET

BASE="base-$BASEBRANCH-$TARGET"

export EPICS_BASE="$HOME/.cache/$BASE"

die() {
  echo "$1" >&1
  exit 1
}

rm -rf build inst

mkdir build
mkdir inst
INST="$PWD/inst"
cd build

case "$TARGET" in
'')
  cmake -DCMAKE_INSTALL_PREFIX=/usr/lib/epics ..
  ;;
win32-x86-mingw)
  cmake -DCMAKE_INSTALL_PREFIX=/usr/lib/epics -DCMAKE_TOOLCHAIN_FILE=$PWD/../toolchains/i686-w64-mingw32.cmake ..  
  ;;
windows-x64-mingw)
  cmake -DCMAKE_INSTALL_PREFIX=/usr/lib/epics -DCMAKE_TOOLCHAIN_FILE=$PWD/../toolchains/x86_64-w64-mingw32.cmake ..  
  ;;
*) die "Unsupported PROF='$PROF'";;
esac

make -j2
make -j2 install VERBOSE=1 DESTDIR="$INST"

cd "$INST"
find .
