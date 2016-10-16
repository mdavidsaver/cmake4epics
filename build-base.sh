#!/bin/sh
set -e -x

[ "$BASEURL" ] || BASEURL=https://github.com/epics-base/epics-base
[ "$BASEBRANCH" ] || BASEBRANCH=3.14
[ "$SHARED" ] || SHARED=YES
# TARGET

BASE="base-$BASEBRANCH-$TARGET-$SHARED"

install -d "$HOME/.build"
git clone --branch "$BASEBRANCH" --depth 10 "$BASEURL" "$HOME/.build/$BASE"

#export EPICS_HOST_ARCH=`sh "$HOME/.build/$BASE/startup/EpicsHostArch"`
#export LD_LIBRARY_PATH="$HOME/.build/$BASE/lib/$EPICS_HOST_ARCH"

install -d "$HOME/.cache/$BASE"
touch "$HOME/.cache/$BASE/built"

BUILT=`cat "$HOME/.cache/$BASE/built"`
HEAD=`cd "$HOME/.build/$BASE" && git log -n1 --pretty=format:%H`

if [ "$HEAD" != "$BUILT" ]; then
  # clear all cached versions
  rm -rf "$HOME/.cache"
  install -d "$HOME/.cache/$BASE"

  if [ "$TARGET" ]; then
    echo "CROSS_COMPILER_TARGET_ARCHS+=$TARGET" >> "$HOME/.build/$BASE/configure/CONFIG_SITE"
  fi

  case "$TARGET" in
  win32-x86-mingw)
    echo "CMPLR_PREFIX = i686-w64-mingw32-" >> "$HOME/.build/$BASE/configure/os/CONFIG_SITE.linux-x86.win32-x86-mingw"
    if [ "$SHARED" = "YES" ]; then
      cat <<EOF >> "$HOME/.build/$BASE/configure/os/CONFIG_SITE.linux-x86.win32-x86-mingw"
SHARED_LIBRARIES = YES
STATIC_BUILD = NO
EOF
    else
      cat <<EOF >> "$HOME/.build/$BASE/configure/os/CONFIG_SITE.linux-x86.win32-x86-mingw"
SHARED_LIBRARIES = NO
STATIC_BUILD = YES
EOF
    fi
    ;;
  windows-x64-mingw)
    echo "CMPLR_PREFIX = x86_64-w64-mingw32-" >> "$HOME/.build/$BASE/configure/os/CONFIG_SITE.linux-x86.windows-x64-mingw"
    if [ "$SHARED" = "YES" ]; then
      cat <<EOF >> "$HOME/.build/$BASE/configure/os/CONFIG_SITE.linux-x86.windows-x64-mingw"
SHARED_LIBRARIES = YES
STATIC_BUILD = NO
EOF
    else
      cat <<EOF >> "$HOME/.build/$BASE/configure/os/CONFIG_SITE.linux-x86.windows-x64-mingw"
SHARED_LIBRARIES = NO
STATIC_BUILD = YES
EOF
    fi
    ;;
  esac

  # TODO LINKER_USE_RPATH=NO
  (cd "$HOME/.build/$BASE" && make -j2 INSTALL_LOCATION="$HOME/.cache/$BASE" )
  
  echo "$HEAD" > "$HOME/.cache/$BASE/built"
fi
