if "%1"=="hide" goto CmdBegin
start mshta vbscript:createobject("wscript.shell").run("""%~0"" hide",0)(window.close)&&exit
:CmdBegin
@REM �������ʵ�ֺ�̨����������

@REM ����: wking [http://wkings.blog]


@REM �ٴε���HKCUһ��
reg.exe import %windir%\youhua\HKCU.reg

@REM ����
rd /s /q %windir%\panther
rd /s /q %windir%\youhua

taskkill /f /im explorer.exe
start explorer.exe

@REM ɾ���Լ�
del /q /f %0
exit