@REM
@REM Collect parameters
@REM

@SET CONFIG=%1

@REM Default parameters

@if not defined CONFIG @SET CONFIG=debug
@if not defined BIN_NAME @SET BIN_NAME=%2
@if not defined MANIFEST_PATH @SET CONFIG=%3

@REM
@REM Script
@REM

@if not defined BIN_NAME @echo Expected BIN_NAME environment variable or as a second argument to this batch file.
@if not defined MANIFEST_PATH @echo Expected MANIFEST_PATH environment variable or as a third argument to this batch file.

@ECHO Build settings:
@echo --
@echo CONFIG=%CONFIG%
@echo BIN_NAME=%BIN_NAME%
@echo MANIFEST_PATH=%MANIFEST_PATH%
@echo --

@echo Building project...

@SET BUILD_ARGS=-c=%CONFIG%

@REM TODO: Enable -cross-module-optimization once Swift compiler properly supports it without crashing
@REM @if %CONFIG%==release @SET BUILD_ARGS=%BUILD_ARGS% -Xswiftc -cross-module-optimization

swift build %BUILD_ARGS%

@if %errorlevel% neq 0 @exit /b %errorlevel%

@echo Preparing binary...

@for /f %%i in ('swift build -c=%CONFIG% --show-bin-path') do @set BIN_DIR=%%i

@SET BIN_PATH=%BIN_DIR%\%BIN_NAME%

mt -nologo -manifest %MANIFEST_PATH% -outputresource:%BIN_PATH%

@echo Done building!
