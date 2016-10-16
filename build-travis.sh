#!/bin/sh
set -e -x

[ "$BASEURL" ] || BASEURL=https://github.com/epics-base/epics-base
[ "$BASEBRANCH" ] || BASEBRANCH=3.14
[ "$SHARED" ] || SHARED=YES
# TARGET

BASE="base-$BASEBRANCH-$TARGET-$SHARED"

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

cmake --version

ARGS="-DCMAKE_INSTALL_PREFIX=/usr/lib/epics -DBUILD_SHARED_LIBS=$SHARED"

case "$TARGET" in
'')
  cmake $ARGS ..
  ;;
win32-x86-mingw)
  cmake $ARGS -DCMAKE_TOOLCHAIN_FILE=$PWD/../toolchains/i686-w64-mingw32.cmake ..  
  ;;
windows-x64-mingw)
  cmake $ARGS -DCMAKE_TOOLCHAIN_FILE=$PWD/../toolchains/x86_64-w64-mingw32.cmake ..  
  ;;
*) die "Unsupported PROF='$PROF'";;
esac

make -j2
make -j2 install VERBOSE=1 DESTDIR="$INST"

cd "$INST"
find .
