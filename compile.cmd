@echo off

echo Will crash with no pramater lol

if %1==-test GOTO test
if %1==-win GOTO comWin
if %1==-windows GOTO comWin
if %1==-mac GOTO comMac
if %1==-macos GOTO comMac
if %1==-macosx GOTO comMac
if %1==-android GOTO comAndroid

:test
lime test windows -debug
exit

:comWin
lime build windows -release
exit

:comMac
lime build mac -release
exit

:comAndroid
lime build android -release
exit
