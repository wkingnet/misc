@REM ʹ��ǰ��: ������������������win10��ͥ���admin�Զ���¼��wim��ʽ�ķ�װĸ�̡�
@REM �ű�ԭ��: �˽ű�����dism��/Set-Edition�����������win10���汾�ϼ�WIM���Ӽ�ͥ�濪ʼ�����������������ʹ�ýű���
@REM �ű�˵��: �ű�Ĭ�ϼ�ͥ�桢�����桢רҵ�桢רҵ�����桢רҵ����վ����ҵ�桢IOT��ҵ��һ��7���汾�������޸ģ������ò����ﰴʵ���޸�
@REM �ű�����: wking [http://wkings.blog/archives/category/technical/sys]

@REM ----------------------------���ò��ֿ�ʼ---------------------------------------

@REM ����wimĸ���ļ�·����wim�ͷ�Ŀ¼��Ҫ������win�汾
@SET WIM_DISK=%~d0
@SET WIM_FILE=h:\install.wim
@SET WIM_DIR=h:\wim
@SET WIM_NUM=7
@SET WIN_VER=Education Professional ProfessionalEducation ProfessionalWorkstation Enterprise IoTEnterprise

@REM UNATTEND_ADMIN��ѡ���á���ָ����admin������ֵ���ļ����á����Ϊ�գ��ű�����ͣ�ȴ��ֶ��滻
@SET UNATTEND_ADMIN=h:\wim_soft\panther\unattend_admin.xml

@REM ----------------------------���ò��ֽ���---------------------------------------

@ECHO OFF
setlocal enabledelayedexpansion

:CHECK
cls
echo �������...
IF NOT DEFINED WIM_FILE echo WIM_FILE�������ô��󣬽ű��˳� & PAUSE & EXIT
IF NOT DEFINED WIMDIR echo WIMDIR�������ô��󣬽ű��˳� & PAUSE & EXIT
IF NOT DEFINED WIN_VER echo WIN_VER�������ô��󣬽ű��˳� & PAUSE & EXIT
IF EXIST %WIM_DISK%\install_backup.wim echo ȷ��install_backup.wim�����ļ����ò��ֶ�ɾ���� & PAUSE
cls
IF EXIST %WIM_DIR%\windows echo wim�ͷ�Ŀ¼%WIM_DIR%û����գ��ֶ���պ��������нű� & PAUSE & EXIT

:���ݾ���
cls
echo ���о��񱸷ݲ���...
copy /V %WIM_FILE% install_backup.wim

:���ؾ���
cls
echo ���й��ؾ������...
Dism /Mount-Wim /WimFile:%WIM_FILE% /Index:1 /MountDir:%WIM_DIR%

:��ͨ�汾����
CALL :VERSION_UPDATE
cls
echo ����ж�ؾ������...
DISM /Unmount-Image /MountDir:%WIM_DIR% /Discard
rename %WIM_FILE% user.wim

:����admin����
cls
echo ��������admin�������...
DISM /Export-Image /SourceImageFile:user.WIM /SourceIndex:1 /DestinationImageFile:install.WIM /Compress:max
Dism /Mount-Wim /WimFile:%WIM_FILE% /Index:1 /MountDir:%WIM_DIR%

:admin����ֵ���ļ��滻
cls
IF DEFINED UNATTEND_ADMIN (
        IF NOT EXIST %UNATTEND_ADMIN% echo admin����ֵ���ļ������ڣ��ֶ��滻�ļ��� & PAUSE & GOTO admin�汾����
        COPY /Y %UNATTEND_ADMIN% %WIM_DIR%\windows\panther\unattend.xml
        GOTO admin�汾����
    ) else (
        echo admin����ֵ���ļ�����δ���壬�ֶ��滻�ļ��� & PAUSE & GOTO admin�汾����
)
pause


:admin�汾����
CALL :VERSION_UPDATE
cls
echo ����ж�ؾ������...
DISM /Unmount-Image /MountDir:%WIM_DIR% /Discard
rename %WIM_FILE% admin.wim

:�ϲ�
@REM ����admin��ͥ��Ϊindex1��������Ӽ�ͥ��admin�������棬������admin...ѭ�����WIM_NUM��һ�����������汾������
    FOR /L %%a IN (1,1,%WIM_NUM%) DO (
        cls
        echo ���ںϲ�����...
        echo %%a
        DISM /Export-Image /SourceImageFile:user.wim /SourceIndex:%%a /DestinationImageFile:install.wim
        DISM /Export-Image /SourceImageFile:admin.wim /SourceIndex:%%a /DestinationImageFile:install.wim
    )
cls
echo ������ϣ���Ʒinstall.wim�����ֶ�ɾ��user.wim��admin.wim�Լ�����install_backup.wim��������������˳�
pause
exit


:VERSION_UPDATE
    FOR %%a IN (%WIN_VER%) DO (
        cls
        echo ���ڽ��а汾����...
        echo %%a
        Dism /Image:%WIM_DIR% /Set-Edition:%%a
        DISM /Commit-Image /MountDir:%WIM_DIR% /Append
    )
    GOTO :EOF