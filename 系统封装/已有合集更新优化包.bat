@REM ʹ��ǰ��: ����ԭ������admin��ϵͳ�ϼ���Ҫ�����Ż�����ԭ�ϼ�����admin����admin�汾����
@REM �ű�����: wking [http://wkings.blog/archives/category/technical/sys]

@REM ----------------------------���ò��ֿ�ʼ---------------------------------------

@REM ����wimĸ���ļ�·����wim�ͷ�Ŀ¼��Ҫ������win�汾��WIM_NUM����Ϊϵͳ�ϼ��е�ϵͳ������YOUHUA_DIRΪ�Ż����ļ���·��
@SET WIM_DISK=%~d0
@SET WIM_FILE=h:\install.wim
@SET WIM_DIR=h:\wim
@SET WIM_NUM=20
@SET YOUHUA_DIR=h:\wim_soft\youhua
@SET UNATTEND=h:\wim_soft\panther\unattend.xml
@SET UNATTEND_ADMIN=h:\wim_soft\panther\unattend_admin.xml

@REM ----------------------------���ò��ֽ���---------------------------------------

@ECHO OFF
setlocal enabledelayedexpansion

:CHECK
cls
echo �������...
IF NOT DEFINED WIM_FILE echo WIM_FILE�������ô��󣬽ű��˳� & PAUSE & EXIT
IF NOT DEFINED WIM_DIR echo WIM_DIR�������ô��󣬽ű��˳� & PAUSE & EXIT
IF NOT DEFINED UNATTEND echo UNATTEND�������ô��󣬽ű��˳� & PAUSE & EXIT
IF EXIST %WIM_DISK%\install_backup.wim echo ȷ��install_backup.wim�����ļ����ò��ֶ�ɾ���� & PAUSE
cls
IF EXIST %WIM_DIR%\windows echo wim�ͷ�Ŀ¼%WIM_DIR%û����գ��ֶ���պ��������нű� & PAUSE & EXIT

:���ݾ���
cls
echo ���о��񱸷ݲ���...
copy /V %WIM_FILE% install_backup.wim

:�����Ż��� ���ݴ�����2ȡ�࣬�����Ƿ�Ϊ1�ж���ż�������ֱ�����admin����admin�汾
FOR /L %%a IN (1,1,%WIM_NUM%) DO (
	set /A "fornum=%%a%%2"
	if !fornum!==1 (
		cls
		echo ����%%a
		echo ����user.wim�����Ż�������...
		Dism /Mount-Wim /WimFile:%WIM_FILE% /Index:%%a /MountDir:%WIM_DIR%
		del /f /q /s %WIM_DIR%\windows\panther\
		del /f /q /s %WIM_DIR%\windows\youhua\
		XCOPY /Y %UNATTEND% %WIM_DIR%\windows\panther\
		XCOPY /Y %YOUHUA_DIR% %WIM_DIR%\windows\youhua\
		Dism /Unmount-Image /MountDir:%WIM_DIR% /Commit
		DISM /Export-Image /SourceImageFile:%WIM_FILE% /SourceIndex:%%a /DestinationImageFile:%WIM_DISK%\final.WIM /Compress:max
	) else (
		cls
		echo ����%%a
		echo ����admin.wim�����Ż�������...
		Dism /Mount-Wim /WimFile:%WIM_FILE% /Index:%%a /MountDir:%WIM_DIR%
		del /f /q /s %WIM_DIR%\windows\panther\
		del /f /q /s %WIM_DIR%\windows\youhua\
		XCOPY /Y %UNATTEND_ADMIN% %WIM_DIR%\windows\panther\
		XCOPY /Y %YOUHUA_DIR% %WIM_DIR%\windows\youhua\
		RENAME %WIM_DIR%\windows\panther\unattend_admin.xml unattend.xml
		Dism /Unmount-Image /MountDir:%WIM_DIR% /Commit
		DISM /Export-Image /SourceImageFile:%WIM_FILE% /SourceIndex:%%a /DestinationImageFile:%WIM_DISK%\final.WIM /Compress:max
	)
)

cls
echo ������ϣ���Ʒfinal.wim����Ʒinstall.wim�����ֶ�ɾ������install_backup.wim & PAUSE & EXIT