copy /Y %RECIPE_DIR%\build_windows.sh build_windows.sh
call %BUILD_PREFIX%\Library\bin\run_autotools_clang_conda_build.bat build_windows.sh
if %ERRORLEVEL% neq 0 exit 1
