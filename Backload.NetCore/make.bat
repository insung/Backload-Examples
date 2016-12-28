@echo off
SETLOCAL
cd %1

:: delete bin, obj
IF EXIST bin (
  call rmdir /s /q bin
)

IF EXIST obj (
  call rmdir /s /q obj
)

:: You need ASP.NET Core
:: You can download from https://www.microsoft.com/net/core

:: build
dotnet publish --runtime ubuntu.14.04.x64 --configuration release

:: 7zip
REM cd ../../../../setup/server_linux/7zip_x86/
REM call 7za.exe a -tzip ../../../deploy/release32/backload_for_linux.zip ../../../src/server/tools/BackloadForLinux/bin/release/netcoreapp1.0/publish/*