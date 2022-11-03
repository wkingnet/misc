@REM 使用前提: 已有原版且有admin的系统合集。要更新优化包。原合集是无admin、有admin版本交错。
@REM 脚本作者: wking [http://wkings.blog/archives/category/technical/sys]

@REM ----------------------------设置部分开始---------------------------------------

@REM 设置wim母盘文件路径、wim释放目录、要升级的win版本。WIM_NUM变量为系统合集中的系统数量。YOUHUA_DIR为优化包文件夹路径
@SET WIM_DISK=%~d0
@SET WIM_FILE=h:\install.wim
@SET WIM_DIR=h:\wim
@SET WIM_NUM=20
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
IF NOT DEFINED UNATTEND echo UNATTEND变量设置错误，脚本退出 & PAUSE & EXIT
IF EXIST %WIM_DISK%\install_backup.wim echo 确认install_backup.wim备份文件无用并手动删除后 & PAUSE
cls
IF EXIST %WIM_DIR%\windows echo wim释放目录%WIM_DIR%没有清空，手动清空后重新运行脚本 & PAUSE & EXIT

:备份镜像
cls
echo 进行镜像备份操作...
copy /V %WIM_FILE% install_backup.wim

:导入优化包 根据次数和2取余，余数是否为1判断奇偶次数，分别处理无admin和有admin版本
FOR /L %%a IN (1,1,%WIM_NUM%) DO (
	set /A "fornum=%%a%%2"
	if !fornum!==1 (
		cls
		echo 索引%%a
		echo 进行user.wim导入优化包操作...
		Dism /Mount-Wim /WimFile:%WIM_FILE% /Index:%%a /MountDir:%WIM_DIR%
		del /f /q /s %WIM_DIR%\windows\panther\
		del /f /q /s %WIM_DIR%\windows\youhua\
		XCOPY /Y %UNATTEND% %WIM_DIR%\windows\panther\
		XCOPY /Y %YOUHUA_DIR% %WIM_DIR%\windows\youhua\
		Dism /Unmount-Image /MountDir:%WIM_DIR% /Commit
		DISM /Export-Image /SourceImageFile:%WIM_FILE% /SourceIndex:%%a /DestinationImageFile:%WIM_DISK%\final.WIM /Compress:max
	) else (
		cls
		echo 索引%%a
		echo 进行admin.wim导入优化包操作...
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
echo 制作完毕，成品final.wim，废品install.wim。可手动删除备份install_backup.wim & PAUSE & EXIT