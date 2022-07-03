set -ex

LDFLAGS="${LDFLAGS} -lucrt.lib"
LDFLAGS="${LDFLAGS} -lvcruntime.lib"
LDFLAGS="${LDFLAGS} -loldnames.lib"

MAKE_FLAGS=
MAKE_FLAGS="${MAKE_FLAGS} LIBSUFFIX=lib"
MAKE_FLAGS="${MAKE_FLAGS} LIBPREFIX= "
MAKE_FLAGS="${MAKE_FLAGS} OS=mingw_nt"
MAKE_FLAGS="${MAKE_FLAGS} CC=${CC}"
MAKE_FLAGS="${MAKE_FLAGS} CXX=${CXX}"
MAKE_FLAGS="${MAKE_FLAGS} AR=${AR}"
MAKE_FLAGS="${MAKE_FLAGS} NM=${NM}"
MAKE_FLAGS="${MAKE_FLAGS} PREFIX=${PREFIX}"
MAKE_FLAGS="${MAKE_FLAGS} ASM=${BUILD_PREFIX}/Library/bin/nasm.exe"

# make ${MAKE_FLAGS} clean
make ${MAKE_FLAGS}
# -j${CPU_COUNT}

make ${MAKE_FLAGS} install
rm ${CYGWIN_PREFIX}/Library/lib/openh264.dll.a

mkdir -p -m755 -v "$PREFIX"/bin
install -m755 -v h264dec "${CYGWIN_PREFIX}/Library/bin/h264dec"
install -m755 -v h264enc "${CYGWIN_PREFIX}/Library/bin/h264enc"
