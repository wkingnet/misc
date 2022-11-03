@REM 脚本作者: wking [http://wkings.blog/archives/550]

@REM ----------------------------设置部分开始---------------------------------------

@REM 设置wim/esd文件路径，WIM_NUM变量为系统合集中的系统数量
@SET WIM_FILE=h:\final.wim
@SET ESD_FILE=h:\final.esd
@SET WIM_NUM=20

@REM ----------------------------设置部分结束---------------------------------------

@ECHO OFF
setlocal enabledelayedexpansion

:生成esd
cls
FOR /L %%a IN (1,1,%WIM_NUM%) DO (
        cls
        echo 正在合并操作...
        echo %%a
        DISM /Export-Image /SourceImageFile:%WIM_FILE% /SourceIndex:%%a /DestinationImageFile:%ESD_FILE% /compress:recovery /CheckIntegrity
    )
cls
echo esd生成完成，成品final.esd & PAUSE & EXIT