@echo off
title Windows FastSetup by Jaser
goto ask_admin
goto performance_mode
goto explorer_setup
goto programs_install
goto taskbar_setup
goto remove_desktop_shortcuts
goto file_associations
goto remove_junk_software
goto visual_preferences
goto end

:ask_admin
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
	echo Administrator privleges not granted!
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params = %*:"=""
    echo UAC.ShellExecute "cmd.exe", "/c %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
	echo Administrator privileges grented!
    pushd "%CD%"
    CD /D "%~dp0"
	
:performance_mode
set Balanced=381b4222-f694-41f0-9685-ff5bb260df2e
set HighPerf=8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
call :MsgBox "Enable performance mode?"  "VBYesNo+VBQuestion" "Question"
if errorlevel 7 (
	echo Turning off game mode...
	cd %systemroot%\system32
	REM Unsetting performance modes
	reg.exe add "HKCU\Software\Microsoft\GameBar" /v "AllowAutoGameMode" /t REG_DWORD /d "0" /f
	reg.exe add "HKCU\Software\Microsoft\GameBar" /v "AutoGameModeEnabled" /t REG_DWORD /d "0" /f
	powercfg -s "%Balanced%"
) else if errorlevel 6 (
	echo Turning on game mode...
	cd %systemroot%\system32
	reg.exe add "HKCU\Software\Microsoft\GameBar" /v "AllowAutoGameMode" /t REG_DWORD /d "1" /f
	reg.exe add "HKCU\Software\Microsoft\GameBar" /v "AutoGameModeEnabled" /t REG_DWORD /d "1" /f
	powercfg -s "%HighPerf%"
)

:explorer_setup
call :MsgBox "Set up Windows Explorer?"  "VBYesNo+VBQuestion" "Question"
if errorlevel 7 (
	echo Windows Explorer settings unchanged!
) else if errorlevel 6 (
	echo Setting up Windows explorer...
	reg.exe add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "LaunchTo" /t REG_DWORD /d "1" /f
	reg.exe add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowRecent" /t REG_DWORD /d "0" /f
	reg.exe add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowFrequent" /t REG_DWORD /d "0" /f
	echo Windows Explorer settings updated.
)

:programs_install
call :MsgBox "Install basic programs?"  "VBYesNo+VBQuestion" "Question"
if errorlevel 7 (
	echo Programs will not be installed!
) else if errorlevel 6 (
	echo Installing basic sofware...
	for %%F in (*.exe) do (
        echo Installing %%F...
        start "" "%%F"
        timeout /t 5 >nul 2>nul
    )
)

:taskbar_setup
call :MsgBox "Set up taskbar?"  "VBYesNo+VBQuestion" "Question"
if errorlevel 7 (
	echo Taskbar stays as is!
) else if errorlevel 6 (
	echo Updating Taskbar settings...
	reg.exe add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "SearchboxTaskbarMode" /t REG_DWORD /d "0" /f
	reg.exe add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowCortanaButton" /t REG_DWORD /d "0" /f
	reg.exe add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowTaskViewButton" /t REG_DWORD /d "0" /f
	reg.exe add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband" /v "FavoritesResolve" /t REG_DWORD /d "0" /f
	echo Taskbar settings updated.
)

:remove_desktop_shortcuts
call :MsgBox "Clean desktop?"  "VBYesNo+VBQuestion" "Question"
if errorlevel 7 (
	echo Desktop stays as is!
) else if errorlevel 6 (
	echo Removing desktop shortcuts...
	del /Q "%USERPROFILE%\Desktop\*.lnk"
	reg.exe add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" /v "{645FF040-5081-101B-9F08-00AA002F954E}" /t REG_DWORD /d "1" /f
	reg.exe add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" /v "{645FF040-5081-101B-9F08-00AA002F954E}" /t REG_DWORD /d "1" /f
	echo Desktop shortcuts removed.
)

:file_associations
call :MsgBox "Associate files with non-crappy Windows programs?"  "VBYesNo+VBQuestion" "Question"
if errorlevel 7 (
	echo File associations stay as the are!
) else if errorlevel 6 (
	echo Setting file associations...
	ftype FoxitReader.Document="C:\Path\to\FoxitReader.exe" "%1"
	assoc .pdf=FoxitReader.Document

	ftype IrfanView.Image="C:\Path\to\IrfanView\i_view64.exe" "%1"
	assoc .bmp=IrfanView.Image
	assoc .jpg=IrfanView.Image
	assoc .jpeg=IrfanView.Image
	assoc .gif=IrfanView.Image
	assoc .png=IrfanView.Image

	ftype VLC.File="C:\Path\to\VLC\vlc.exe" "%1"
	assoc .avi=VLC.File
	assoc .mp4=VLC.File
	assoc .mkv=VLC.File
	assoc .mp3=VLC.File
	assoc .wav=VLC.File

	assoc .htm=ChromeHTML
	assoc .html=ChromeHTML
	assoc .shtml=ChromeHTML
	assoc .xht=ChromeHTML
	assoc .xhtml=ChromeHTML

	echo File associations set.
)

:remove_junk_software
call :MsgBox "Remove junk Windows apps?"  "VBYesNo+VBQuestion" "Question"
if errorlevel 7 (
	echo Windows junk stays in place!
) else if errorlevel 6 (
	echo Removing pre-installed Windows junk software...
	PowerShell.exe -Command "Get-AppxPackage -Name Microsoft.MicrosoftStickyNotes* | Remove-AppxPackage -AllUsers"
	PowerShell.exe -Command "Get-AppxPackage -Name Microsoft.Windows.SnippingTool* | Remove-AppxPackage -AllUsers"
	PowerShell.exe -Command "Get-AppxPackage -Name Microsoft.MicrosoftSolitaireCollection* | Remove-AppxPackage -AllUsers"
	PowerShell.exe -Command "Get-AppxPackage -Name Microsoft.MSPaint* | Remove-AppxPackage -AllUsers"
	PowerShell.exe -Command "Get-AppxPackage -Name Microsoft.Xbox* | Remove-AppxPackage -AllUsers"
	PowerShell.exe -Command "Get-AppxPackage -Name Microsoft.OneDrive* | Remove-AppxPackage -AllUsers"
	PowerShell.exe -Command "Get-AppxPackage -Name Microsoft.SkypeApp* | Remove-AppxPackage -AllUsers"
	PowerShell.exe -Command "Get-AppxPackage -Name Microsoft.SkypeForBusiness* | Remove-AppxPackage -AllUsers"
	PowerShell.exe -Command "Get-AppxPackage -Name Microsoft.BingWeather* | Remove-AppxPackage -AllUsers"
	PowerShell.exe -Command "Get-AppxPackage -Name Microsoft.BingNews* | Remove-AppxPackage -AllUsers"
	PowerShell.exe -Command "Get-AppxPackage -Name Microsoft.WindowsSoundRecorder* | Remove-AppxPackage -AllUsers"
	echo Pre-installed Windows junk software removed.
)

:visual_preferences
call :MsgBox "Adjust visuals?"  "VBYesNo+VBQuestion" "Question"
if errorlevel 7 (
	echo Visual settings stay as is!
) else if errorlevel 6 (
	echo Adjusting visual preferences...
	reg.exe add "HKEY_CURRENT_USER\Control Panel\Mouse" /v "CursorScheme" /t REG_SZ /d "Windows Inverted" /f
	reg.exe add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "EnableTransparency" /t REG_DWORD /d "0" /f
	reg.exe add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "AppsUseLightTheme" /t REG_DWORD /d "0" /f
	echo Visual preferences adjusted.
)

:MsgBox prompt type title
setlocal enableextensions
set "tempFile=%temp%\%~nx0.%random%%random%%random%vbs.tmp"
>"%tempFile%" echo(WScript.Quit msgBox("%~1",%~2,"%~3") & cscript //nologo //e:vbscript "%tempFile%"
set "exitCode=%errorlevel%" & del "%tempFile%" >nul 2>nul
endlocal & exit /b %exitCode%

:end
pause
exit
