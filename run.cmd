@if not defined CONFIG @SET CONFIG=debug

CALL build.cmd

@if %errorlevel% neq 0 @exit /b %errorlevel%

@echo Executing...

chcp 65001

%BIN_PATH%
