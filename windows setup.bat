@echo off
title Windows FastSetup by Jaser
goto ask_admin
goto performance_mode
goto explorer_setup
goto programs_install
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
REM Game mode sw
call :MsgBox "Enable performance mode?"  "VBYesNo+VBQuestion" "Question"
if errorlevel 7 (
	echo Turning off game mode...
	@echo off
	Title Executing registry editor operation...
	cd %systemroot%\system32
	Reg.exe add "HKCU\Software\Microsoft\GameBar" /v "AllowAutoGameMode" /t REG_DWORD /d "0" /f
	Reg.exe add "HKCU\Software\Microsoft\GameBar" /v "AutoGameModeEnabled" /t REG_DWORD /d "0" /f
	powercfg -s "%Balanced%"
) else if errorlevel 6 (
	echo Turning on game mode...
	@echo off
	Title Executing registry editor operation...
	cd %systemroot%\system32
	Reg.exe add "HKCU\Software\Microsoft\GameBar" /v "AllowAutoGameMode" /t REG_DWORD /d "1" /f
	Reg.exe add "HKCU\Software\Microsoft\GameBar" /v "AutoGameModeEnabled" /t REG_DWORD /d "1" /f
	powercfg -s "%HighPerf%"
)

:explorer_setup
call :MsgBox "Set up Windows Explorer?"  "VBYesNo+VBQuestion" "Question"
if errorlevel 7 (
	echo Windows Explorer settings unchanged!
) else if errorlevel 6 (
	echo Setting up Windows explorer...
	@echo off
	echo Updating Windows Explorer settings...
	
	REM Set 'Open File Explorer to' to 'This PC'
	reg.exe add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "LaunchTo" /t REG_DWORD /d "1" /f

	REM Uncheck 'Show recently used files in Quick access'
	reg.exe add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowRecent" /t REG_DWORD /d "0" /f

	REM Uncheck 'Show frequently used folders in Quick access'
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

	REM Remove search bar and search icon from the taskbar
	reg.exe add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "SearchboxTaskbarMode" /t REG_DWORD /d "0" /f

	REM Remove Cortana from the taskbar
	reg.exe add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowCortanaButton" /t REG_DWORD /d "0" /f

	REM Remove Taskbar button from the taskbar
	reg.exe add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowTaskViewButton" /t REG_DWORD /d "0" /f
	
	REM Remove Microsoft Edge from the taskbar
	reg.exe add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband" /v "FavoritesResolve" /t REG_DWORD /d "0" /f

echo Taskbar settings updated.
)

:remove_desktop_shortcuts
@echo off
echo Removing desktop shortcuts...

REM Remove program icons
del /Q "%USERPROFILE%\Desktop\*.lnk"

REM Remove Recycle Bin
reg.exe add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" /v "{645FF040-5081-101B-9F08-00AA002F954E}" /t REG_DWORD /d "1" /f
reg.exe add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" /v "{645FF040-5081-101B-9F08-00AA002F954E}" /t REG_DWORD /d "1" /f

echo Desktop shortcuts removed.

:file_associations
@echo off
echo Setting file associations...

REM Associate PDF files with Foxit PDF Reader
ftype FoxitReader.Document="C:\Path\to\FoxitReader.exe" "%1"
assoc .pdf=FoxitReader.Document

REM Associate image files with IrfanView
ftype IrfanView.Image="C:\Path\to\IrfanView\i_view64.exe" "%1"
assoc .bmp=IrfanView.Image
assoc .jpg=IrfanView.Image
assoc .jpeg=IrfanView.Image
assoc .gif=IrfanView.Image
assoc .png=IrfanView.Image

REM Associate video and audio files with VLC
ftype VLC.File="C:\Path\to\VLC\vlc.exe" "%1"
assoc .avi=VLC.File
assoc .mp4=VLC.File
assoc .mkv=VLC.File
assoc .mp3=VLC.File
assoc .wav=VLC.File

REM Associate browser-related extensions with Chrome
assoc .htm=ChromeHTML
assoc .html=ChromeHTML
assoc .shtml=ChromeHTML
assoc .xht=ChromeHTML
assoc .xhtml=ChromeHTML

echo File associations set.

:remove_junk_software
@echo off
echo Removing pre-installed Windows junk software...

REM Remove Sticky Notes
PowerShell.exe -Command "Get-AppxPackage -Name Microsoft.MicrosoftStickyNotes* | Remove-AppxPackage -AllUsers"

REM Remove Snipping Tool
PowerShell.exe -Command "Get-AppxPackage -Name Microsoft.Windows.SnippingTool* | Remove-AppxPackage -AllUsers"

REM Remove Solitaire Collection
PowerShell.exe -Command "Get-AppxPackage -Name Microsoft.MicrosoftSolitaireCollection* | Remove-AppxPackage -AllUsers"

REM Remove Paint 3D
PowerShell.exe -Command "Get-AppxPackage -Name Microsoft.MSPaint* | Remove-AppxPackage -AllUsers"

REM Remove Xbox programs
PowerShell.exe -Command "Get-AppxPackage -Name Microsoft.Xbox* | Remove-AppxPackage -AllUsers"

REM Remove OneDrive
PowerShell.exe -Command "Get-AppxPackage -Name Microsoft.OneDrive* | Remove-AppxPackage -AllUsers"

REM Remove Skype
PowerShell.exe -Command "Get-AppxPackage -Name Microsoft.SkypeApp* | Remove-AppxPackage -AllUsers"

REM Remove Skype for Business
PowerShell.exe -Command "Get-AppxPackage -Name Microsoft.SkypeForBusiness* | Remove-AppxPackage -AllUsers"

REM Remove Weather
PowerShell.exe -Command "Get-AppxPackage -Name Microsoft.BingWeather* | Remove-AppxPackage -AllUsers"

REM Remove News
PowerShell.exe -Command "Get-AppxPackage -Name Microsoft.BingNews* | Remove-AppxPackage -AllUsers"

REM Remove Sound Recorder
PowerShell.exe -Command "Get-AppxPackage -Name Microsoft.WindowsSoundRecorder* | Remove-AppxPackage -AllUsers"

echo Pre-installed Windows junk software removed.

:visual_preferences
@echo off
echo Adjusting visual preferences...

REM Set mouse cursor type to Windows inverted (system scheme)
reg.exe add "HKEY_CURRENT_USER\Control Panel\Mouse" /v "CursorScheme" /t REG_SZ /d "Windows Inverted" /f

REM Turn off transparency effect
reg.exe add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "EnableTransparency" /t REG_DWORD /d "0" /f

REM Turn on dark mode
reg.exe add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "AppsUseLightTheme" /t REG_DWORD /d "0" /f

echo Visual preferences adjusted.

:MsgBox prompt type title
setlocal enableextensions
set "tempFile=%temp%\%~nx0.%random%%random%%random%vbs.tmp"
>"%tempFile%" echo(WScript.Quit msgBox("%~1",%~2,"%~3") & cscript //nologo //e:vbscript "%tempFile%"
set "exitCode=%errorlevel%" & del "%tempFile%" >nul 2>nul
endlocal & exit /b %exitCode%

:end
pause
exit
