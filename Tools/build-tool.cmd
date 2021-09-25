@SET TOOL_NAME=%1
@if not defined TOOL_NAME @echo Expected tool name as first argument to this batch file.

@SET TARGET_FOLDER=bin
@if not exist %TARGET_FOLDER%\ (
    @MKDIR %TARGET_FOLDER%
)

@SET BIN_PATH=%TARGET_FOLDER%\%TOOL_NAME%.exe

@swiftc %TOOL_NAME%.swift -o %BIN_PATH% -sdk %SDKROOT% -I %SDKROOT%/usr/lib/swift -L %SDKROOT%/usr/lib/swift/windows
