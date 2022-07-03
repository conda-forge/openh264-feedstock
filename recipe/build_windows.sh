set -ex

MAKE_FLAGS=
MAKE_FLAGS="${MAKE_FLAGS} LIBSUFFIX=lib"
MAKE_FLAGS="${MAKE_FLAGS} LIBPREFIX= "
MAKE_FLAGS="${MAKE_FLAGS} OS=mingw_nt"
MAKE_FLAGS="${MAKE_FLAGS} CC=x86_64-w64-mingw32-gcc"
MAKE_FLAGS="${MAKE_FLAGS} CXX=x86_64-w64-mingw32-g++"
MAKE_FLAGS="${MAKE_FLAGS} AR=x86_64-w64-mingw32-gcc-ar"
MAKE_FLAGS="${MAKE_FLAGS} NM=x86_64-w64-mingw32-gcc-nm"
MAKE_FLAGS="${MAKE_FLAGS} PREFIX=${CYGWIN_PREFIX}/Library"
MAKE_FLAGS="${MAKE_FLAGS} ASM=${BUILD_PREFIX}/Library/bin/nasm.exe"

# make ${MAKE_FLAGS} clean
make ${MAKE_FLAGS} -j${CPU_COUNT}

make ${MAKE_FLAGS} install
rm ${CYGWIN_PREFIX}/Library/lib/openh264.dll.a

mkdir -p -m755 -v "$PREFIX"/bin
install -m755 -v h264dec "${CYGWIN_PREFIX}/Library/bin/h264dec"
install -m755 -v h264enc "${CYGWIN_PREFIX}/Library/bin/h264enc"
