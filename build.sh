#!/bin/sh

TARGET=ios,iossimulator,macos
OUTPUT=IPtProxy.xcframework
TEMPDIR="$TMPDIR/IPtProxy"

if [ "$1" = "android" ]; then
  TARGET=android
  OUTPUT=IPtProxy.aar
  MIN_VERSION=28

  NDK_SOURCE_PROPERTIES="$ANDROID_NDK_HOME/source.properties"

  if [ ! -f "$NDK_SOURCE_PROPERTIES" ]; then
    echo "--- Android NDK not found or too old."
    exit 1
  fi

  NDK_VERSION=$(grep "Pkg.Revision" "$NDK_SOURCE_PROPERTIES" | cut -d' ' -f3)

  NDK_MAJOR_VERSION=${NDK_VERSION%%.*}

  if [ "$NDK_MAJOR_VERSION" -lt "$MIN_VERSION" ]; then
    echo "--- Android NDK version $NDK_VERSION too old. Use at least version $MIN_VERSION."
    exit 1
  fi
fi

cd "$(dirname "$0")" || exit 1

if [ -e $OUTPUT ]; then
    echo "--- No build necessary, $OUTPUT already exists."
    exit
fi

# Install dependencies. Go itself is a prerequisite.
printf '\n--- Golang 1.24 or up needs to be installed! Try "brew install go" on MacOS or "snap install go" on Linux if we fail further down!'
printf '\n--- Installing gomobile...\n'
go install golang.org/x/mobile/cmd/gomobile@latest

# Prepare build environment
printf '\n\n--- Prepare build environment at %s...\n' "$TEMPDIR"
CURRENT=$PWD
rm -rf "$TEMPDIR"
mkdir -p "$TEMPDIR"
cp -a IPtProxy.go "$TEMPDIR/"

# Compile framework.
printf '\n\n--- Compile %s...\n' "$OUTPUT"
export PATH=~/go/bin:$PATH
cd "$TEMPDIR/IPtProxy.go" || exit 1

gomobile init

MACOSX_DEPLOYMENT_TARGET=11.0 gomobile bind -target=$TARGET -ldflags="-s -w -checklinkname=0" -o "$CURRENT/$OUTPUT" -iosversion=12.0 -androidapi=21 -v -tags=netcgo -trimpath

### Note:
# $ go tool link -h
#  -s	disable symbol table
#  -w	disable DWARF generation
#
# -> Saves > 50% of file size on all targets!
# See https://github.com/guardianproject/orbot/pull/1061

rm -rf "$TEMPDIR"

printf '\n\n--- Done.\n\n'
