@echo off
title Windows setup script by Greg 1.0

set "flag=0"

call :MsgBox "Do you want to stop at each task?" "VBYesNo+VBQuestion" "Safe mode"
if errorlevel 7 (
	set "flag=1"
	msg * The operation will stop at each task
) else if errorlevel 6 (
	msg * The operation will NOT stop at each task
)

:: Administrator privileges check
>nul 2>&1 "%SYSTEMROOT%\System32\cacls.exe" "%SYSTEMROOT%\System32\config\system"
if %errorlevel% == 0 (
    echo Admin privileges granted.
	call :TaskQueue :: Starting operation
	goto :EOF
) else (
    echo Admin privileges are required to run this script.
    echo Please run the script as an administrator.
    pause
    exit /b 1
)

:TaskQueue
	:: Tasks call
    call :Task1 :: Creating performance power plan, turning on game mode
    call :Task2 :: Installing Chocolatey
    call :Task3 :: Installing programs via Chocolatey
    call :Task4 :: Resetting Windows Photos and Movies & TV
    call :Task5 :: Setting default file associations
    call :Task6 :: Applying aesthetic modifications
    call :Task7 :: Updating Store apps
    call :Task8 :: Removing shortcuts from desktop
	call :Task9 :: Uninstall junk Windows Store apps
	pause
    goto :EOF

:Task1
	echo Task 1 is executing...
	:: Create a new performance-oriented power plan
	powercfg -duplicatescheme 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
	:: Configure the power plan settings
	powercfg -setacvalueindex 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 4f971e89-eebd-4455-a8de-9e59040e7347 5ca83367-6e45-459f-a27b-476b1d01c936 0
	powercfg -setacvalueindex 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 4f971e89-eebd-4455-a8de-9e59040e7347 7648efa3-dd9c-4e3e-b566-50f929386280 0
	powercfg -setacvalueindex 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 4f971e89-eebd-4455-a8de-9e59040e7347 96996bc0-ad50-47ec-923b-6f41874dd9eb 0
	powercfg -setacvalueindex 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 4f971e89-eebd-4455-a8de-9e59040e7347 238c9fa8-0aad-41ed-83f4-97be242c8f20 0
	:: Enable Game Mode
	reg add "HKEY_CURRENT_USER\Software\Microsoft\GameBar" /v AllowAutoGameMode /t REG_DWORD /d 1 /f
	echo Performance power plan created and Game Mode enabled.
	if !flag! == 1 ( pause )
	goto :EOF

:Task2
	echo Task 2 is executing...
	:: Open a new PowerShell console with execution policy bypass
	powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))"
	echo Chocolatey installed.
	if !flag! == 1 ( pause )
	goto :EOF

:Task3
	echo Task 3 is executing...
	:: Install programs using Chocolatey with -y flag
	choco install -y chrome
	choco install -y irfanview
	choco install -y vlc
	choco install -y foxitreader
	choco install -y audacity
	choco install -y notepadplusplus
	choco install -y hdsentinel
	choco install -y unreal-commander
	:: Install Core Temp without ad stuff
	choco install -y coretemp --ignore-checksums --allow-empty-checksums
	echo Programs installed with Chocolatey.
	if !flag! == 1 ( pause )
	goto :EOF

:Task4
	echo Task 4 is executing...
	:: Reset Windows Photos
	powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-AppxPackage Microsoft.Windows.Photos | Reset-AppxPackage"
	:: Reset Windows Movies & TV
	powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-AppxPackage Microsoft.Microsoft3DViewer | Reset-AppxPackage"
	echo Windows Photos and Video app reset.
	if !flag! == 1 ( pause )
	goto :EOF

:Task5
	echo Task 5 is executing...
	:: Set image associations to IrfanView
	assoc .jpg=IrfanView.jpg
	assoc .jpeg=IrfanView.jpeg
	assoc .png=IrfanView.png
	ftype IrfanView.jpg="%ProgramFiles%\IrfanView\i_view32.exe" "%%1"
	ftype IrfanView.jpeg="%ProgramFiles%\IrfanView\i_view32.exe" "%%1"
	ftype IrfanView.png="%ProgramFiles%\IrfanView\i_view32.exe" "%%1"
	:: Set audio and video formats to VLC
	assoc .mp3=VLC.mp3
	assoc .mp4=VLC.mp4
	ftype VLC.mp3="%ProgramFiles%\VideoLAN\VLC\vlc.exe" "%%1"
	ftype VLC.mp4="%ProgramFiles%\VideoLAN\VLC\vlc.exe" "%%1"
	:: Set PDF to Foxit PDF Reader
	assoc .pdf=Foxit.PDF
	ftype Foxit.PDF="%ProgramFiles%\Foxit Software\Foxit Reader\FoxitReader.exe" "%%1"
	:: Set Chrome as the default browser
	ftype http="C:\Program Files\Google\Chrome\Application\chrome.exe" "%%1"
	ftype https="C:\Program Files\Google\Chrome\Application\chrome.exe" "%%1"
	echo Default program associations updated.
	if !flag! == 1 ( pause )
	goto :EOF

:Task6
	echo Task 6 is executing...
	:: Aesthetic modifications
	:: Turn on Dark Mode
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v AppsUseLightTheme /t REG_DWORD /d 0 /f
	:: Turn off Transparency Effects
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v EnableTransparency /t REG_DWORD /d 0 /f
	:: Set cursor to Windows Inverted (system scheme)
	reg add "HKCU\Control Panel\Mouse" /v CursorScheme /t REG_SZ /d "Windows Inverted (system scheme)" /f
	:: Set default startup location of Windows Explorer to This PC
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v LaunchTo /t REG_DWORD /d 1 /f
	:: Disable history tracking in Quick access
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v Start_TrackDocs /t REG_DWORD /d 0 /f
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v Start_TrackProgs /t REG_DWORD /d 0 /f
	:: Show file extensions and hidden files
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v HideFileExt /t REG_DWORD /d 0 /f
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v Hidden /t REG_DWORD /d 1 /f
	:: Hiding taskbar search bar
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v SearchboxTaskbarMode /t REG_DWORD /d 0 /f
	:: Hiding Task view button
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ShowTaskViewButton /t REG_DWORD /d 0 /f
	:: Hiding Recycle bin from the desktop:
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" /v {645FF040-5081-101B-9F08-00AA002F954E} /t REG_DWORD /d 1 /f
	echo Aesthetic settings applied.
	if !flag! == 1 ( pause )
	goto :EOF

:Task7
	echo Task 7 is executing...
	:: Update all Microsoft Store apps
	powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-AppxPackage -AllUsers | Where-Object { $_.PublisherId -like '*Microsoft*'} | Foreach { Add-AppxPackage -DisableDevelopmentMode -Register ""$($_.InstallLocation)\AppXManifest.xml"" }"
	echo Microsoft Store apps updated.
	if !flag! == 1 ( pause )
	goto :EOF

:Task8
	echo Task 8 is executing...
	:: Remove all shortcuts from the desktop
	del /q %userprofile%\Desktop\*.lnk
	echo All shortcuts removed from the desktop.
	if !flag! == 1 ( pause )
	goto :EOF

:Task9
	echo Task 9 is executing...
	:: Uninstall junk Windows Store apps
	powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-AppxPackage -AllUsers | Where-Object { $_.Name -in @('MicrosoftStickyNotes', 'Microsoft.MSnWeather', 'MicrosoftSolitaireCollection', 'Microsoft.ChimpChamp', 'Microsoft.ZuneMusic', 'Microsoft.WindowsSnippingTool', 'Microsoft.BingNews', 'Microsoft.WindowsSoundRecorder', 'Microsoft.PowerAutomateDesktop', 'MicrosoftTeams', 'Skype', 'OneDrive') } | Remove-AppxPackage -ErrorAction SilentlyContinue"
	echo Junk apps uninstalled.
	if !flag! == 1 ( pause )
	goto :EOF

:MsgBox prompt type title
	setlocal enableextensions
	set "tempFile=%temp%\%~nx0.%random%%random%%random%vbs.tmp"
	>"%tempFile%" echo(WScript.Quit msgBox("%~1",%~2,"%~3") & cscript //nologo //e:vbscript "%tempFile%"
	set "exitCode=%errorlevel%" & del "%tempFile%" >nul 2>nul
	endlocal & exit /b %exitCode%
