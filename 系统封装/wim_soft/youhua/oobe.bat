@REM 作者: wking [http://wkings.blog]

@REM 计划任务程序
@REM 禁用-磁盘碎片整理计划
@REM SCHTASKS /End /TN "\Microsoft\Windows\Defrag\ScheduledDefrag" >NUL 2>NUL
@REM SCHTASKS /Change /TN "\Microsoft\Windows\Defrag\ScheduledDefrag" /DISABLE >NUL 2>NUL

@REM 控制面板: 电源选项
@REM 开启休眠 (关闭了休眠, 发现开机启动太慢)
POWERCFG /H ON >NUL 2>NUL
@REM 10分钟-关闭显示器
POWERCFG /CHANGE monitor-timeout-ac 10 >NUL 2>NUL
POWERCFG /CHANGE monitor-timeout-dc 10 >NUL 2>NUL
@REM 从不-使计算机进入睡眠状态
POWERCFG /CHANGE standby-timeout-ac 0 >NUL 2>NUL
POWERCFG /CHANGE standby-timeout-dc 0 >NUL 2>NUL
@REM 30分钟-在此时间后关闭硬盘  0为不关闭
POWERCFG /CHANGE disk-timeout-ac 30 >NUL 2>NUL
POWERCFG /CHANGE disk-timeout-dc 30 >NUL 2>NUL
@REM 从不-计算机进入休眠状态的时间
POWERCFG /CHANGE hibernate-timeout-ac 0 >NUL 2>NUL
POWERCFG /CHANGE hibernate-timeout-dc 0 >NUL 2>NUL

@REM 打开小娜
reg.exe delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v AllowCortana /f

@REM 静默安装7-ZIP
start /wait %windir%\youhua\7-zip.exe /S
del /f /q %userprofile%\desktop\7-zip.lnk

@REM 再次导入HKCU一次
reg.exe import %windir%\youhua\HKCU.reg

@REM 微软输入法默认英文
reg.exe add "HKCU\SOFTWARE\Microsoft\InputMethod\Settings\CHS" /v "Default Mode" /t REG_DWORD /d 00000001 /f

@REM 允许我为每个应用窗口使用不同的输入法  打钩=9e1e078092000000  不打钩=9e1e078012000000  设置立刻生效，但设置面板显示需要重启或注销才更新
reg.exe add "HKCU\Control Panel\Desktop" /v "UserPreferencesMask" /t REG_BINARY  /d 9e1e078092000000 /f

@REM 解压缩驱动精灵到ALL.USER桌面 不内置了
@REM start /wait %windir%\youhua\7z.exe x %~dp0Drivergenius.zip -o%PUBLIC%\Desktop

@REM 解压缩WindowsDefender.zip 不内置了
@REM "%ProgramFiles%\7-zip\7z.exe" x %~dp0WindowsDefender.zip -o%PUBLIC%\Desktop

@REM 添加StartUp.bat到注册表自启，进桌面后执行。OOBE阶段部分修改不生效
copy %windir%\youhua\StartUp.bat %windir%\system32 /y
reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce /v 1 /t reg_sz /d "StartUp.bat" /f
exit