@echo on

:: When cross-compiling (e.g. a win-64 host building win-arm64), the Windows
:: compiler activation scripts do not generate a meson cross file the way the
:: unix ones do. Without a cross file meson assumes a native build and tries to
:: run the freshly built (arm64) sanity-check executable on the (x64) build host,
:: which fails with "WinError 216 ... not compatible with the version of Windows".
::
:: We also cannot use MSVC (cl) for the arm64 assembly: openh264's meson build
:: needs gas-preprocessor.pl + armasm64 for aarch64 with MSVC, and
:: gas-preprocessor is not packaged on conda-forge. Instead we build with
:: clang-cl, which assembles the NEON .S files directly (openh264 takes the
:: `cpp_sources += asm_sources` path when the compiler id is clang-cl).
::
:: The --target lives in the compiler command itself (not in a [built-in
:: options] c_args entry), so meson sees the arm64 target during compiler
:: detection and stamps the right /MACHINE on the static linker (lib.exe). If
:: --target were only in c_args, detection would see clang-cl's default arch
:: and lib.exe would fail with LNK1112 (module type ARM64 conflicts with x64).
::
:: Use the "aarch64" spelling of the triple, NOT "arm64": meson canonicalizes
:: the compiler target by testing 'aarch64' in target before 'arm' in target
:: (mesonbuild/compilers/mixins/visualstudio.py). "arm64" contains "arm" but not
:: "aarch64", so meson would pick 32-bit /MACHINE:arm and lib.exe would fail with
:: LNK1112 (module type ARM64 conflicts with target ARM). clang treats the two
:: triples identically.
::
:: NOTE: keep comments OUT of the parenthesized if-block below -- cmd parses the
:: whole block regardless of the condition, and a stray ")" in a "::" comment
:: (or the comment itself) breaks parsing for every platform, not just arm64.
if "%CONDA_BUILD_CROSS_COMPILATION%" == "1" (
  echo Cross compiling for %target_platform%; writing meson cross file
  echo [binaries]> "%SRC_DIR%\conda_meson_cross_file.txt"
  echo c = ['clang-cl', '--target=aarch64-pc-windows-msvc']>> "%SRC_DIR%\conda_meson_cross_file.txt"
  echo cpp = ['clang-cl', '--target=aarch64-pc-windows-msvc']>> "%SRC_DIR%\conda_meson_cross_file.txt"
  echo [host_machine]>> "%SRC_DIR%\conda_meson_cross_file.txt"
  echo system = 'windows'>> "%SRC_DIR%\conda_meson_cross_file.txt"
  echo cpu_family = 'aarch64'>> "%SRC_DIR%\conda_meson_cross_file.txt"
  echo cpu = 'aarch64'>> "%SRC_DIR%\conda_meson_cross_file.txt"
  echo endian = 'little'>> "%SRC_DIR%\conda_meson_cross_file.txt"
  type "%SRC_DIR%\conda_meson_cross_file.txt"
  set "MESON_ARGS=%MESON_ARGS% --cross-file %SRC_DIR%\conda_meson_cross_file.txt"
)

:: %MESON_ARGS% is set by the compiler activation scripts and carries the
:: prefix, libdir, pkg-config path and buildtype (plus the cross file above).
meson setup builddir ^
  %MESON_ARGS% ^
  --backend=ninja ^
  -Dtests=disabled
if errorlevel 1 exit 1

 %BUILD_PREFIX%\Scripts\meson.exe configure builddir
 if errorlevel 1 exit 1

 ninja -v -C builddir -j %CPU_COUNT%
 if errorlevel 1 exit 1

 ninja -C builddir install -j %CPU_COUNT%
 if errorlevel 1 exit 1

 copy /Y builddir\codec\console\enc\h264enc.exe %LIBRARY_PREFIX%\bin\h264enc.exe
 copy /Y builddir\codec\console\dec\h264dec.exe %LIBRARY_PREFIX%\bin\h264dec.exe
