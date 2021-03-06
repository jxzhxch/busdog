:: ddk environment
if "%1"=="64" (
    call C:\WinDDK\7600.16385.1\bin\setenv.bat C:\WinDDK\7600.16385.1\ fre x64 WNET no_oacr 
) else (
    call C:\WinDDK\7600.16385.1\bin\setenv.bat C:\WinDDK\7600.16385.1\ fre x86 WXP no_oacr 
)
if "%1"=="64" (
    set other_arch_spec=amd64
) else (
    set other_arch_spec=i386
)
cd %~dp0

:: build busdog filter driver
build -ceZg
if exist build%BUILD_ALT_DIR%.err goto error
echo +++++++++++++++++++++++++++++++++
echo +++busdog filter driver built!+++
echo +++++++++++++++++++++++++++++++++

:: sign driver
SignTool sign /f testcert.pfx /p test /t http://timestamp.verisign.com/scripts/timestamp.dll filter\obj%BUILD_ALT_DIR%\%other_arch_spec%\busdog.sys
if errorlevel 1 goto error
echo +++++++++++++++++++++++++++++++++++++++
echo +++busdog filter driver test signed!+++
echo +++++++++++++++++++++++++++++++++++++++

:: copy driver to busdog gui directory
xcopy /Y filter\obj%BUILD_ALT_DIR%\%other_arch_spec%\busdog.sys gui\driverRes\bin
if errorlevel 1 goto error
xcopy /Y filter\obj%BUILD_ALT_DIR%\%other_arch_spec%\busdog.pdb gui\driverRes\bin
if errorlevel 1 goto error
xcopy /Y filter\obj%BUILD_ALT_DIR%\%other_arch_spec%\busdog.inf gui\driverRes\bin
if errorlevel 1 goto error
xcopy /Y %BASEDIR%\redist\wdf\%_BUILDARCH%\wdfcoinstaller?????.dll gui\driverRes\bin
if errorlevel 1 goto error
xcopy /Y %BASEDIR%\redist\DIFx\dpinst\MultiLin\%_BUILDARCH%\dpinst.exe gui\driverRes\bin
if errorlevel 1 goto error

::visual studio environment
if exist "c:\Program Files (x86)" (
    call "C:\Program Files (x86)\Microsoft Visual Studio 9.0\VC\vcvarsall.bat" x86
) else (
    call "C:\Program Files\Microsoft Visual Studio 9.0\VC\vcvarsall.bat" x86
)
if errorlevel 1 goto error
cd %~dp0

:: build busdog gui
cd gui
msbuild build.xml /t:clean
if errorlevel 1 goto error
msbuild build.xml /t:release
if errorlevel 1 goto error
echo +++++++++++++++++++++++
echo +++busdog gui built!+++
echo +++++++++++++++++++++++


:: finito!
goto end

:error
echo +++++++++++++++++++++
echo +++Error in build!+++
echo +++++++++++++++++++++
cd %~dp0
exit /B 1

:end
cd %~dp0
exit /B 0


