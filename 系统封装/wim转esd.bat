@REM �ű�����: wking [http://wkings.blog/archives/550]

@REM ----------------------------���ò��ֿ�ʼ---------------------------------------

@REM ����wim/esd�ļ�·����WIM_NUM����Ϊϵͳ�ϼ��е�ϵͳ����
@SET WIM_FILE=h:\final.wim
@SET ESD_FILE=h:\final.esd
@SET WIM_NUM=20

@REM ----------------------------���ò��ֽ���---------------------------------------

@ECHO OFF
setlocal enabledelayedexpansion

:����esd
cls
FOR /L %%a IN (1,1,%WIM_NUM%) DO (
        cls
        echo ���ںϲ�����...
        echo %%a
        DISM /Export-Image /SourceImageFile:%WIM_FILE% /SourceIndex:%%a /DestinationImageFile:%ESD_FILE% /compress:recovery /CheckIntegrity
    )
cls
echo esd������ɣ���Ʒfinal.esd & PAUSE & EXIT