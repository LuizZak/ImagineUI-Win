@ECHO OFF

SETLOCAL

REM
REM Collect parameters
REM

IF "%~1"=="" (
    SET CONFIG=debug
) ELSE (
    SET CONFIG=%1
)

REM
REM Script
REM

CALL config 1> NUL

ECHO Build settings:
ECHO --
ECHO CONFIG=%CONFIG%
ECHO BIN_NAME=%BIN_NAME%
ECHO MANIFEST_PATH=%MANIFEST_PATH%
ECHO --

ECHO Building project...

SET BUILD_ARGS=-c=%CONFIG%

REM TODO: Enable -cross-module-optimization once Swift compiler properly supports it without crashing
REM if %CONFIG%==release SET BUILD_ARGS=%BUILD_ARGS% -Xswiftc -cross-module-optimization

swift build %BUILD_ARGS%

IF %errorlevel% neq 0 (
    EXIT /b %errorlevel%
)

ECHO Preparing binary...

FOR /f %%i IN ('swift build %BUILD_ARGS% --show-bin-path') DO (
    SET BIN_DIR=%%i
)

SET BIN_PATH=%BIN_DIR%\%BIN_NAME%

mt -nologo -manifest %MANIFEST_PATH% -outputresource:%BIN_PATH%

ECHO Done building!
