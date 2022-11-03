if "%1"=="hide" goto CmdBegin
start mshta vbscript:createobject("wscript.shell").run("""%~0"" hide",0)(window.close)&&exit
:CmdBegin

@REM 作者: wking [http://blog.wkings.net/archives/550]


@REM 再次导入HKCU一次
reg.exe import %windir%\youhua\HKCU.reg

@REM 清理
rd /s /q %windir%\panther
rd /s /q %windir%\youhua

taskkill /f /im explorer.exe
start explorer.exe

del /f /q "%ProgramData%\Microsoft\Windows\Start Menu\Programs\StartUp\StartUp.bat"
