@REM ʹ��ǰ��: ����ԭ������admin��ϵͳ�ϼ���Ҫ�����Ż���������admin�ʻ��汾��
@REM �ű�����: wking [http://wkings.blog/archives/category/technical/sys]

@REM ----------------------------���ò��ֿ�ʼ---------------------------------------

@REM ����wimĸ���ļ�·����wim�ͷ�Ŀ¼��Ҫ������win�汾��WIM_NUM����Ϊϵͳ�ϼ��е�ϵͳ������YOUHUA_DIRΪ�Ż����ļ���·��
@SET WIM_DISK=%~d0
@SET WIM_FILE=h:\install.wim
@SET WIM_DIR=h:\wim
@SET WIM_NUM=10
@SET WIN_VER=Education Professional ProfessionalEducation ProfessionalWorkstation Enterprise IoTEnterprise
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
IF NOT DEFINED WIN_VER echo WIN_VER�������ô��󣬽ű��˳� & PAUSE & EXIT
IF NOT DEFINED UNATTEND echo UNATTEND�������ô��󣬽ű��˳� & PAUSE & EXIT
IF EXIST %WIM_DISK%\install_backup.wim echo ȷ��install_backup.wim�����ļ����ò��ֶ�ɾ���� & PAUSE
REM IF EXIST %WIM_DIR%\windows echo wim�ͷ�Ŀ¼%WIM_DIR%û����գ��ֶ���պ��������нű� & PAUSE & EXIT
RD wim
MD wim
cls


:���ݾ���
cls
echo ���о��񱸷ݲ���...
copy /V %WIM_FILE% install_backup.wim

:�����Ż���
FOR /L %%a IN (1,1,%WIM_NUM%) DO (
        cls
        echo ����%%a
        echo ����user.wim�����Ż�������...
        Dism /Mount-Wim /WimFile:%WIM_FILE% /Index:%%a /MountDir:%WIM_DIR%
        XCOPY /Y %UNATTEND% %WIM_DIR%\windows\panther\
        XCOPY /Y %YOUHUA_DIR% %WIM_DIR%\windows\youhua\
        Dism /Unmount-Image /MountDir:%WIM_DIR% /Commit
        DISM /Export-Image /SourceImageFile:%WIM_FILE% /SourceIndex:%%a /DestinationImageFile:USER.WIM /Compress:max
        cls
        echo ����%%a
        echo ����admin.wim�����Ż�������...
        Dism /Mount-Wim /WimFile:%WIM_FILE% /Index:%%a /MountDir:%WIM_DIR%
        del /f /q /s %WIM_DIR%\windows\panther\unattend.xml
        XCOPY /Y %UNATTEND_ADMIN% %WIM_DIR%\windows\panther\
        RENAME %WIM_DIR%\windows\panther\unattend_admin.xml unattend.xml
        Dism /Unmount-Image /MountDir:%WIM_DIR% /Commit
        DISM /Export-Image /SourceImageFile:%WIM_FILE% /SourceIndex:%%a /DestinationImageFile:ADMIN.WIM /Compress:max
    )
    
:�ϲ�
FOR /L %%a IN (1,1,%WIM_NUM%) DO (
        cls
        echo ���ںϲ�����...
        echo %%a
        DISM /Export-Image /SourceImageFile:user.wim /SourceIndex:%%a /DestinationImageFile:final.wim
        DISM /Export-Image /SourceImageFile:admin.wim /SourceIndex:%%a /DestinationImageFile:final.wim
    )
   
RD wim
cls
echo ������ϣ���Ʒfinal.wim����Ʒinstall.wim�����ֶ�ɾ��user.wim��admin.wim�Լ�����install_backup.wim & PAUSE & EXIT