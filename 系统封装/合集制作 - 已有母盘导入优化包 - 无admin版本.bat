@REM 使用前提: 已有原版且无admin的系统合集。要加入优化包且增加admin帐户版本。
@REM 脚本作者: wking [http://wkings.blog/archives/category/technical/sys]

@REM ----------------------------设置部分开始---------------------------------------

@REM 设置wim母盘文件路径、wim释放目录、要升级的win版本。WIM_NUM变量为系统合集中的系统数量。YOUHUA_DIR为优化包文件夹路径
@SET WIM_DISK=%~d0
@SET WIM_FILE=h:\install.wim
@SET WIM_DIR=h:\wim
@SET WIM_NUM=10
@SET WIN_VER=Education Professional ProfessionalEducation ProfessionalWorkstation Enterprise IoTEnterprise
@SET YOUHUA_DIR=h:\wim_soft\youhua
@SET UNATTEND=h:\wim_soft\panther\unattend.xml
@SET UNATTEND_ADMIN=h:\wim_soft\panther\unattend_admin.xml

@REM ----------------------------设置部分结束---------------------------------------

@ECHO OFF
setlocal enabledelayedexpansion

:CHECK
cls
echo 环境检查...
IF NOT DEFINED WIM_FILE echo WIM_FILE变量设置错误，脚本退出 & PAUSE & EXIT
IF NOT DEFINED WIM_DIR echo WIM_DIR变量设置错误，脚本退出 & PAUSE & EXIT
IF NOT DEFINED WIN_VER echo WIN_VER变量设置错误，脚本退出 & PAUSE & EXIT
IF NOT DEFINED UNATTEND echo UNATTEND变量设置错误，脚本退出 & PAUSE & EXIT
IF EXIST %WIM_DISK%\install_backup.wim echo 确认install_backup.wim备份文件无用并手动删除后 & PAUSE
REM IF EXIST %WIM_DIR%\windows echo wim释放目录%WIM_DIR%没有清空，手动清空后重新运行脚本 & PAUSE & EXIT
RD wim
MD wim
cls


:备份镜像
cls
echo 进行镜像备份操作...
copy /V %WIM_FILE% install_backup.wim

:导入优化包
FOR /L %%a IN (1,1,%WIM_NUM%) DO (
        cls
        echo 索引%%a
        echo 进行user.wim导入优化包操作...
        Dism /Mount-Wim /WimFile:%WIM_FILE% /Index:%%a /MountDir:%WIM_DIR%
        XCOPY /Y %UNATTEND% %WIM_DIR%\windows\panther\
        XCOPY /Y %YOUHUA_DIR% %WIM_DIR%\windows\youhua\
        Dism /Unmount-Image /MountDir:%WIM_DIR% /Commit
        DISM /Export-Image /SourceImageFile:%WIM_FILE% /SourceIndex:%%a /DestinationImageFile:USER.WIM /Compress:max
        cls
        echo 索引%%a
        echo 进行admin.wim导入优化包操作...
        Dism /Mount-Wim /WimFile:%WIM_FILE% /Index:%%a /MountDir:%WIM_DIR%
        del /f /q /s %WIM_DIR%\windows\panther\unattend.xml
        XCOPY /Y %UNATTEND_ADMIN% %WIM_DIR%\windows\panther\
        RENAME %WIM_DIR%\windows\panther\unattend_admin.xml unattend.xml
        Dism /Unmount-Image /MountDir:%WIM_DIR% /Commit
        DISM /Export-Image /SourceImageFile:%WIM_FILE% /SourceIndex:%%a /DestinationImageFile:ADMIN.WIM /Compress:max
    )
    
:合并
FOR /L %%a IN (1,1,%WIM_NUM%) DO (
        cls
        echo 正在合并操作...
        echo %%a
        DISM /Export-Image /SourceImageFile:user.wim /SourceIndex:%%a /DestinationImageFile:final.wim
        DISM /Export-Image /SourceImageFile:admin.wim /SourceIndex:%%a /DestinationImageFile:final.wim
    )
   
RD wim
cls
echo 制作完毕，成品final.wim，废品install.wim。可手动删除user.wim、admin.wim以及备份install_backup.wim & PAUSE & EXIT