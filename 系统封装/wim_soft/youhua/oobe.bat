@REM ����: wking [http://wkings.blog]

@REM �ƻ��������
@REM ����-������Ƭ����ƻ�
@REM SCHTASKS /End /TN "\Microsoft\Windows\Defrag\ScheduledDefrag" >NUL 2>NUL
@REM SCHTASKS /Change /TN "\Microsoft\Windows\Defrag\ScheduledDefrag" /DISABLE >NUL 2>NUL

@REM �������: ��Դѡ��
@REM �������� (�ر�������, ���ֿ�������̫��)
POWERCFG /H ON >NUL 2>NUL
@REM 10����-�ر���ʾ��
POWERCFG /CHANGE monitor-timeout-ac 10 >NUL 2>NUL
POWERCFG /CHANGE monitor-timeout-dc 10 >NUL 2>NUL
@REM �Ӳ�-ʹ���������˯��״̬
POWERCFG /CHANGE standby-timeout-ac 0 >NUL 2>NUL
POWERCFG /CHANGE standby-timeout-dc 0 >NUL 2>NUL
@REM 30����-�ڴ�ʱ���ر�Ӳ��  0Ϊ���ر�
POWERCFG /CHANGE disk-timeout-ac 30 >NUL 2>NUL
POWERCFG /CHANGE disk-timeout-dc 30 >NUL 2>NUL
@REM �Ӳ�-�������������״̬��ʱ��
POWERCFG /CHANGE hibernate-timeout-ac 0 >NUL 2>NUL
POWERCFG /CHANGE hibernate-timeout-dc 0 >NUL 2>NUL

@REM ��С��
reg.exe delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v AllowCortana /f

@REM ��Ĭ��װ7-ZIP
start /wait %windir%\youhua\7-zip.exe /S
del /f /q %userprofile%\desktop\7-zip.lnk

@REM �ٴε���HKCUһ��
reg.exe import %windir%\youhua\HKCU.reg

@REM ΢�����뷨Ĭ��Ӣ��
reg.exe add "HKCU\SOFTWARE\Microsoft\InputMethod\Settings\CHS" /v "Default Mode" /t REG_DWORD /d 00000001 /f

@REM ������Ϊÿ��Ӧ�ô���ʹ�ò�ͬ�����뷨  ��=9e1e078092000000  ����=9e1e078012000000  ����������Ч�������������ʾ��Ҫ������ע���Ÿ���
reg.exe add "HKCU\Control Panel\Desktop" /v "UserPreferencesMask" /t REG_BINARY  /d 9e1e078092000000 /f

@REM ��ѹ���������鵽ALL.USER���� ��������
@REM start /wait %windir%\youhua\7z.exe x %~dp0Drivergenius.zip -o%PUBLIC%\Desktop

@REM ��ѹ��WindowsDefender.zip ��������
@REM "%ProgramFiles%\7-zip\7z.exe" x %~dp0WindowsDefender.zip -o%PUBLIC%\Desktop

@REM ���StartUp.bat��ע����������������ִ�С�OOBE�׶β����޸Ĳ���Ч
copy %windir%\youhua\StartUp.bat %windir%\system32 /y
reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce /v 1 /t reg_sz /d "StartUp.bat" /f
exit