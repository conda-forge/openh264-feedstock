copy /Y %RECIPE_DIR%\build_windows.sh build_windows.sh
bash build_windows.sh
if %ERRORLEVEL% neq 0 exit 1
