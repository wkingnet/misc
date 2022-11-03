rd /s /q i:\wim_soft\panther
rd /s /q i:\wim_soft\youhua

md i:\wim_soft\panther
md i:\wim_soft\youhua

xcopy ..\wim_soft\panther i:\wim_soft\panther /e /y
xcopy ..\wim_soft\youhua i:\wim_soft\youhua /e /y

pause