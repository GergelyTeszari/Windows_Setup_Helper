@echo off

set win_ver=0
set run_history=0
set history_file_name=WSH.kredenc

:: Administrator privileges check
>nul 2>&1 "%SYSTEMROOT%\System32\cacls.exe" "%SYSTEMROOT%\System32\config\system"
if %errorlevel%==0 (
    echo Admin privileges granted.
    :: Tasks call(
        call :Check_for_internet_connection
	call :Task1 :: Power config update
        call :Task2 :: Installing programs via Winget
        call :Task3 :: Resetting Windows Photos and Movies & TV        
        call :Task4 :: Applying aesthetic modifications
        call :Task5 :: Updating Store apps
        call :Task6 :: Removing shortcuts from desktop
        call :Task7 :: Uninstall junk Windows Store apps
    )
	pause
    goto :EOF
) else (
    echo Admin privileges are required to run this script.
    echo Please run the script as an administrator.
    pause
    exit /b 1
)

:Windows_version_check
    :: Getting Windows version
    setlocal enabledelayedexpansion
    for /f "tokens=4-6 delims=. " %%i in ('ver') do (
        set VERSION=%%i.%%j.
        set BUILD=%%k
    )
    echo Windows version MAJOR.MINOR: !VERSION!
    echo Windows version BUILD: !BUILD!
    if !BUILD! geq 22000 (
        echo Windows version detected: 11
        set win_ver = 11
        title Windows 11 setup
    ) else if !VERSION! == 10.0. (
        echo Windows version detected: 10
        set win_ver = 10
        title Windows 10 setup script
    ) else if !VERSION! == 6.3. (
        echo Windows version detected: 8.1
        call :Compatibility_mode_message
    ) else if !VERSION! == 6.2. (
        echo Windows version detected: 8
        call :Compatibility_mode_message
    ) else if !VERSION! == 6.1. (
        echo Windows version detected: 7
        call :Compatibility_mode_message
    ) else if !VERSION! == 6.0. (
        echo Windows version detected: Vista
        call :Compatibility_mode_message
    ) else (
        echo Unknown Windows Version
        call :Compatibility_mode_message
    )
    endlocal
    goto :EOF

:Compatibility_mode_message
    setlocal enabledelayedexpansion
    title Windows setup COMPATIBILITY MODE
    echo WARNING! The correct operation of the script was not tested with this Windows version. Proceed at your own risk.
    set /p "confirmation=Do you want to proceed? (y/n): "
    if /i "!confirmation!"=="y" (
        echo Proceeding...
        goto :EOF
    ) else (
        echo The script is terminating...
        pause
		exit /b 1
    )
    endlocal
    exit /b 1

:Check_for_internet_connection
    setlocal enabledelayedexpansion
    set "counter=0"
    set "maxAttempts=10"
    set "delaySeconds=2"

    echo Checking for internet connection...

    :PingLoop
    set /a "counter+=1"
    ping -n 1 8.8.8.8 >nul

    if %errorlevel% equ 0 (
        echo Internet connection detected.
        goto :EOF
    ) else (
        echo Attempt !counter! of !maxAttempts! failed. Waiting for !delaySeconds! seconds before the next attempt...
        timeout /t %delaySeconds% /nobreak >nul
    )

    if !counter! lss !maxAttempts! goto :PingLoop

    echo Maximum attempts reached. Exiting the script.
	endlocal
	pause
	exit /b 1

:Task1
    echo Task 1 is executing...
    :: Create a new performance-oriented power plan
    powercfg -duplicatescheme 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
    :: Configure the power plan settings for battery mode
    powercfg -setdcvalueindex 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 4f971e89-eebd-4455-a8de-9e59040e7347 5ca83367-6e45-459f-a27b-476b1d01c936 0
    powercfg -setdcvalueindex 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 4f971e89-eebd-4455-a8de-9e59040e7347 7648efa3-dd9c-4e3e-b566-50f929386280 0
    :: Configure the power plan settings for plugged-in mode
    powercfg -setacvalueindex 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 4f971e89-eebd-4455-a8de-9e59040e7347 5ca83367-6e45-459f-a27b-476b1d01c936 0
    powercfg -setacvalueindex 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 4f971e89-eebd-4455-a8de-9e59040e7347 7648efa3-dd9c-4e3e-b566-50f929386280 0
    :: Handle PC-specific settings
    wmic computersystem get model | find /i /v "Notebook" | find /i /v "Laptop" >nul
    if %errorlevel% equ 0 (
        :: Configure PC-specific settings
        powercfg -setdcvalueindex 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 4f971e89-eebd-4455-a8de-9e59040e7347 96996bc0-ad50-47ec-923b-6f41874dd9eb 0
        powercfg -setacvalueindex 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 4f971e89-eebd-4455-a8de-9e59040e7347 96996bc0-ad50-47ec-923b-6f41874dd9eb 0
        powercfg -setdcvalueindex 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 4f971e89-eebd-4455-a8de-9e59040e7347 238c9fa8-0aad-41ed-83f4-97be242c8f20 0
        powercfg -setacvalueindex 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 4f971e89-eebd-4455-a8de-9e59040e7347 238c9fa8-0aad-41ed-83f4-97be242c8f20 0
    )
    :: Activate the newly created power plan
    powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
    :: Enable Game Mode
    reg add "HKEY_CURRENT_USER\Software\Microsoft\GameBar" /v AutoGameModeEnabled /t REG_DWORD /d 1 /f
    echo Performance power plan created and Game Mode enabled.
    goto :EOF

:Task2
    echo Task 3 is executing...
	winget install 7zip.7zip                              
	winget install AIMP.AIMP                              
	winget install Audacity.Audacity                      
	winget install Buanzo.FFmpegforAudacity
	winget install GIMP.GIMP.3                            
	winget install IrfanSkiljan.IrfanView                 
	winget install FlorianHeidenreich.Mp3tag              
	winget install Notepad++.Notepad++                    
	winget install VideoLAN.VLC                           
	winget install Logitech.GHUB                          
	winget install Google.Chrome                          
	winget install Plex.PlexMediaServer                   
	winget install Inkscape.Inkscape                      
	winget install Microsoft.VisualStudioCode
	:: Arduino
	winget install 9NBLGGH4RSD8
	winget install JanosMathe.HardDiskSentinel.Standard
	winget install OBSProject.OBSStudio
	winget install MaxDiesel.UnrealCommander
	winget install AltDrag.AltDrag                        
	winget install Gyan.FFmpeg                            
	winget install WinDirStat.WinDirStat                  
	winget install Microsoft.PowerToys
	winget install Notepad++.Notepad++
	winget install Python.Python.3.11
    winget install ALCPU.CoreTemp

    echo Programs are successfully installed with Winget.

    goto :EOF

:Task3
    echo Task 4 is executing...
    :: Reset Windows Photos
    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-AppxPackage -Name Microsoft.Windows.Photos | Reset-AppxPackage"
    :: Reset Windows Movies & TV
    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-AppxPackage -Name Microsoft.ZuneVideo | Reset-AppxPackage"
    echo Windows Photos and Video app reset.
    goto :EOF

:Task4
    echo Task 6 is executing...
    :: Aesthetic modifications
    :: Turn on Dark Mode
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v AppsUseLightTheme /t REG_DWORD /d 0 /f
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v SystemUsesLightTheme /t REG_DWORD /d 0 /f
    :: Turn off Transparency Effects
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v EnableTransparency /t REG_DWORD /d 0 /f
    :: Set cursor to Windows Inverted (system scheme)
    reg add "HKCU\Control Panel\Cursors" /v "AppStarting" /t REG_EXPAND_SZ /d "%%SystemRoot%%\cursors\wait_i.cur" /f
    reg add "HKCU\Control Panel\Cursors" /v "Arrow" /t REG_EXPAND_SZ /d "%%SystemRoot%%\cursors\arrow_i.cur" /f
    reg add "HKCU\Control Panel\Cursors" /v "ContactVisualization" /t REG_DWORD /d "1" /f
    reg add "HKCU\Control Panel\Cursors" /v "Crosshair" /t REG_EXPAND_SZ /d "%%SystemRoot%%\cursors\cross_i.cur" /f
    reg add "HKCU\Control Panel\Cursors" /v "CursorBaseSize" /t REG_DWORD /d "32" /f
    reg add "HKCU\Control Panel\Cursors" /v "GestureVisualization" /t REG_DWORD /d "31" /f
    reg add "HKCU\Control Panel\Cursors" /v "Hand" /t REG_EXPAND_SZ /d "%%SystemRoot%%\cursors\aero_link_i.cur" /f
    reg add "HKCU\Control Panel\Cursors" /v "Help" /t REG_EXPAND_SZ /d "%%SystemRoot%%\cursors\help_i.cur" /f
    reg add "HKCU\Control Panel\Cursors" /v "IBeam" /t REG_EXPAND_SZ /d "%%SystemRoot%%\cursors\beam_i.cur" /f
    reg add "HKCU\Control Panel\Cursors" /v "No" /t REG_EXPAND_SZ /d "%%SystemRoot%%\cursors\no_i.cur" /f
    reg add "HKCU\Control Panel\Cursors" /v "NWPen" /t REG_EXPAND_SZ /d "%%SystemRoot%%\cursors\pen_i.cur" /f
    reg add "HKCU\Control Panel\Cursors" /v "Scheme Source" /t REG_DWORD /d "2" /f
    reg add "HKCU\Control Panel\Cursors" /v "SizeAll" /t REG_EXPAND_SZ /d "%%SystemRoot%%\cursors\move_i.cur" /f
    reg add "HKCU\Control Panel\Cursors" /v "SizeNESW" /t REG_EXPAND_SZ /d "%%SystemRoot%%\cursors\size1_i.cur" /f
    reg add "HKCU\Control Panel\Cursors" /v "SizeNS" /t REG_EXPAND_SZ /d "%%SystemRoot%%\cursors\size4_i.cur" /f
    reg add "HKCU\Control Panel\Cursors" /v "SizeNWSE" /t REG_EXPAND_SZ /d "%%SystemRoot%%\cursors\size2_i.cur" /f
    reg add "HKCU\Control Panel\Cursors" /v "SizeWE" /t REG_EXPAND_SZ /d "%%SystemRoot%%\cursors\size3_i.cur" /f
    reg add "HKCU\Control Panel\Cursors" /v "UpArrow" /t REG_EXPAND_SZ /d "%%SystemRoot%%\cursors\up_i.cur" /f
    reg add "HKCU\Control Panel\Cursors" /v "Wait" /t REG_EXPAND_SZ /d "%%SystemRoot%%\cursors\busy_i.cur" /f
    reg add "HKCU\Control Panel\Cursors" /ve /t REG_SZ /d "Windows Inverted" /f
    reg add "HKCU\Control Panel\Cursors" /v "Pin" /t REG_EXPAND_SZ /d "%%SystemRoot%%\cursors\pin_i.cur" /f
    reg add "HKCU\Control Panel\Cursors" /v "Person" /t REG_EXPAND_SZ /d "%%SystemRoot%%\cursors\person_i.cur" /f
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
    :: Incrementing history
	%run_history%=6
    call :Push_local_run_history
    goto :EOF

:Task5
    echo Task 7 is executing...
    :: Update all Microsoft Store apps
    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "winget update --all --accept-source-agreements --accept-package-agreements"
    echo Microsoft Store apps updated.
    goto :EOF

:Task6
    echo Task 8 is executing...
    :: Remove all shortcuts from the desktop
    del /q %userprofile%\Desktop\*.lnk
    echo All shortcuts removed from the desktop.
    :: Incrementing history
	%run_history%=8
    call :Push_local_run_history
    goto :EOF

:Task7
    echo Task 9 is executing...
    :: Uninstall junk Windows Store apps
    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-AppxPackage -AllUsers | Where-Object { $_.Name -in @('MicrosoftStickyNotes', 'Microsoft.MSnWeather', 'MicrosoftSolitaireCollection', 'Microsoft.ChimpChamp', 'Microsoft.WindowsSnippingTool', 'Microsoft.BingNews', 'Microsoft.WindowsSoundRecorder', 'Microsoft.PowerAutomateDesktop', 'MicrosoftTeams', 'Skype', 'OneDrive') } | Remove-AppxPackage -ErrorAction SilentlyContinue"
    echo Junk apps uninstalled.
    :: Incrementing history
	%run_history%=9
    call :Push_local_run_history
    goto :EOF

