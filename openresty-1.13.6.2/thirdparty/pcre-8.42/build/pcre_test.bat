@REM This is a generated file.
@echo off
setlocal
SET srcdir="D:\www\_openresty\openresty-1.13.6.2\thirdparty\pcre-8.42"
SET pcretest="D:\www\_openresty\openresty-1.13.6.2\thirdparty\pcre-8.42\build\DEBUG\pcretest.exe"
if not [%CMAKE_CONFIG_TYPE%]==[] SET pcretest="D:\www\_openresty\openresty-1.13.6.2\thirdparty\pcre-8.42\build\%CMAKE_CONFIG_TYPE%\pcretest.exe"
call %srcdir%\RunTest.Bat
if errorlevel 1 exit /b 1
echo RunTest.bat tests successfully completed
