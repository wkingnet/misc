@REM 使用前提: 你事先已另行制作好win10家庭版非admin自动登录的wim格式的封装母盘。
@REM 脚本原理: 此脚本利用dism的/Set-Edition命令快速制作win10各版本合集WIM。从家庭版开始升级。其他情况请勿使用脚本。
@REM 脚本说明: 脚本默认家庭版、教育版、专业版、专业教育版、专业工作站、企业版、IOT企业版一共7个版本。如需修改，在设置部分里按实际修改
@REM 脚本作者: wking [http://wkings.blog/archives/category/technical/sys]

@REM ----------------------------设置部分开始---------------------------------------

@REM 设置wim母盘文件路径、wim释放目录、要升级的win版本
@SET WIM_DISK=%~d0
@SET WIM_FILE=h:\install.wim
@SET WIM_DIR=h:\wim
@SET WIM_NUM=7
@SET WIN_VER=Education Professional ProfessionalEducation ProfessionalWorkstation Enterprise IoTEnterprise

@REM UNATTEND_ADMIN可选设置。可指定带admin的无人值守文件设置。如果为空，脚本会暂停等待手动替换
@SET UNATTEND_ADMIN=h:\wim_soft\panther\unattend_admin.xml

@REM ----------------------------设置部分结束---------------------------------------

@ECHO OFF
setlocal enabledelayedexpansion

:CHECK
cls
echo 环境检查...
IF NOT DEFINED WIM_FILE echo WIM_FILE变量设置错误，脚本退出 & PAUSE & EXIT
IF NOT DEFINED WIMDIR echo WIMDIR变量设置错误，脚本退出 & PAUSE & EXIT
IF NOT DEFINED WIN_VER echo WIN_VER变量设置错误，脚本退出 & PAUSE & EXIT
IF EXIST %WIM_DISK%\install_backup.wim echo 确认install_backup.wim备份文件无用并手动删除后 & PAUSE
cls
IF EXIST %WIM_DIR%\windows echo wim释放目录%WIM_DIR%没有清空，手动清空后重新运行脚本 & PAUSE & EXIT

:备份镜像
cls
echo 进行镜像备份操作...
copy /V %WIM_FILE% install_backup.wim

:挂载镜像
cls
echo 进行挂载镜像操作...
Dism /Mount-Wim /WimFile:%WIM_FILE% /Index:1 /MountDir:%WIM_DIR%

:普通版本制作
CALL :VERSION_UPDATE
cls
echo 进行卸载镜像操作...
DISM /Unmount-Image /MountDir:%WIM_DIR% /Discard
rename %WIM_FILE% user.wim

:生成admin镜像
cls
echo 进行生成admin镜像操作...
DISM /Export-Image /SourceImageFile:user.WIM /SourceIndex:1 /DestinationImageFile:install.WIM /Compress:max
Dism /Mount-Wim /WimFile:%WIM_FILE% /Index:1 /MountDir:%WIM_DIR%

:admin无人值守文件替换
cls
IF DEFINED UNATTEND_ADMIN (
        IF NOT EXIST %UNATTEND_ADMIN% echo admin无人值守文件不存在，手动替换文件后 & PAUSE & GOTO admin版本制作
        COPY /Y %UNATTEND_ADMIN% %WIM_DIR%\windows\panther\unattend.xml
        GOTO admin版本制作
    ) else (
        echo admin无人值守文件变量未定义，手动替换文件后 & PAUSE & GOTO admin版本制作
)
pause


:admin版本制作
CALL :VERSION_UPDATE
cls
echo 进行卸载镜像操作...
DISM /Unmount-Image /MountDir:%WIM_DIR% /Discard
rename %WIM_FILE% admin.wim

:合并
@REM 以无admin家庭版为index1，依次添加家庭版admin，教育版，教育版admin...循环里的WIM_NUM是一共制作几个版本的数量
    FOR /L %%a IN (1,1,%WIM_NUM%) DO (
        cls
        echo 正在合并操作...
        echo %%a
        DISM /Export-Image /SourceImageFile:user.wim /SourceIndex:%%a /DestinationImageFile:install.wim
        DISM /Export-Image /SourceImageFile:admin.wim /SourceIndex:%%a /DestinationImageFile:install.wim
    )
cls
echo 制作完毕，成品install.wim。可手动删除user.wim、admin.wim以及备份install_backup.wim。任意键继续并退出
pause
exit


:VERSION_UPDATE
    FOR %%a IN (%WIN_VER%) DO (
        cls
        echo 正在进行版本升级...
        echo %%a
        Dism /Image:%WIM_DIR% /Set-Edition:%%a
        DISM /Commit-Image /MountDir:%WIM_DIR% /Append
    )
    GOTO :EOF