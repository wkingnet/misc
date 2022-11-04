if "%1"=="hide" goto CmdBegin
start mshta vbscript:createobject("wscript.shell").run("""%~0"" hide",0)(window.close)&&exit
:CmdBegin
@REM 上面代码实现后台运行批处理

@REM 作者: wking [http://wkings.blog]


@REM 再次导入HKCU一次
reg.exe import %windir%\youhua\HKCU.reg

@REM 清理
rd /s /q %windir%\panther
rd /s /q %windir%\youhua

taskkill /f /im explorer.exe
start explorer.exe

@REM 删除自己
del /q /f %0
exit