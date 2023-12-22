@echo off

set win_ver = 0
set run_history = 0

:: Administrator privileges check
>nul 2>&1 "%SYSTEMROOT%\System32\cacls.exe" "%SYSTEMROOT%\System32\config\system"
if %errorlevel% == 0 (
    echo Admin privileges granted.
    :: Tasks call
    call :Windows_version_check
    call :Check_for_previous_runs
    if %run_history% == 0 (
        call :Task1 :: Creating performance power plan, turning on game mode
    ) else if %run_history% == 1 (
        call :Check_for_internet_connection
        call :Task2 :: Installing Chocolatey
    ) else if %run_history% == 2 (
        call :Check_for_internet_connection
        call :Task3 :: Installing programs via Chocolatey        
    ) else if %run_history% == 3 (
        call :Task4 :: Resetting Windows Photos and Movies & TV        
    ) else if %run_history% == 4 (
        call :Task5 :: Setting default file associations
    ) else if %run_history% == 5 (
        call :Task6 :: Applying aesthetic modifications
    ) else if %run_history% == 6 (
        call :Check_for_internet_connection
        call :Task7 :: Updating Store apps
    ) else if %run_history% == 7 (
        call :Task8 :: Removing shortcuts from desktop
    ) else if %run_history% == 8 (
        call :Task9 :: Uninstall junk Windows Store apps
    ) else if %run_history% == 9 (
        :: Task 10
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
    )
    endlocal
    exit /b 1

:Check_for_previous_runs
    reg query "HKCU\Software\Windows_setup_script" /v Windows_setup_script_execution_state >nul 2>&1
    if %errorlevel% neq 0 (
        echo Run history not found.
        call :Create_run_history
        goto :EOF
    ) else (
        echo Run history found.
        call :Update_local_run_history
        echo Restored to local variable: %run_history%
        goto :EOF
    )

:Create_run_history
    echo Creating run history...
    reg add "HKCU\Software\Windows_setup_script" /v Windows_setup_script_execution_state /t REG_DWORD /d 0 /f >nul 2>&1
    echo created empty run history.
    goto :EOF

:Update_local_run_history
    echo Querying data from registry...
    for /f "tokens=3" %%A in ('reg query "HKCU\Software\Windows_setup_script" /v Windows_setup_script_execution_state ^| find "REG_DWORD"') do set query_result=%%A
    if not defined exec_state_from_registry (
        echo Run history not found, query unsuccesful.
    ) else (
        echo Query result from registry: %query_result%
        set run_history=%query_result:~2%
    )
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
    :: Activate the newly created power plan
    powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
    :: Enable Game Mode
    reg add "HKEY_CURRENT_USER\Software\Microsoft\GameBar" /v AutoGameModeEnabled /t REG_DWORD /d 1 /f
    echo Performance power plan created and Game Mode enabled.
    :: Incrementing history
    reg add "HKCU\Software\Windows_setup_script" /v Windows_setup_script_execution_state /t REG_DWORD /d 1 /f >nul 2>&1
    call :Update_local_run_history
    goto :EOF

:Check_for_internet_connection
    setlocal enabledelayedexpansion
    :: Function to check for internet connection
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
    goto :EOF

:Task2
    echo Task 2 is executing...
    :: Open a new PowerShell console with execution policy bypass
    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))"
    echo Chocolatey installed.
    :: Incrementing history
    reg add "HKCU\Software\Windows_setup_script" /v Windows_setup_script_execution_state /t REG_DWORD /d 2 /f >nul 2>&1
    call :Update_local_run_history
    goto :EOF


:Task3
    echo Task 3 is executing...
    :: Install programs using Chocolatey with -y flag
    echo Installing Chrome...
    choco install GoogleChrome -y
    echo Installing IrfanView...
    choco install Irfanview -y
    echo installing VLC...
    choco install vlc -y
    echo Installing Foxit PDF reader...
    choco install FoxitReader -y
    echo Installing Audacity...
    choco install audacity -y
    echo Installing NP++...
    choco install notepadplusplus -y
    echo Installing HD sentinel...
    choco install hdsentinel -y
    echo Installing UnCom...
    choco install unreal-commander -y
    echo Installing Core Temp...
    choco install coretemp -y
    echo Programs are successfully installed with Chocolatey.
    :: Incrementing history
    reg add "HKCU\Software\Windows_setup_script" /v Windows_setup_script_execution_state /t REG_DWORD /d 3 /f >nul 2>&1
    call :Update_local_run_history
    goto :EOF

:Task4
    echo Task 4 is executing...
    :: Reset Windows Photos
    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-AppxPackage -Name Microsoft.Windows.Photos | Reset-AppxPackage"
    :: Reset Windows Movies & TV
    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-AppxPackage -Name Microsoft.ZuneVideo | Reset-AppxPackage"
    echo Windows Photos and Video app reset.
    :: Incrementing history
    reg add "HKCU\Software\Windows_setup_script" /v Windows_setup_script_execution_state /t REG_DWORD /d 4 /f >nul 2>&1
    call :Update_local_run_history
    goto :EOF

:Task5
    echo Task 5 is executing...
    choco install setuserfta -y
    SetUserFTA .3g2 VLC.3g2
    SetUserFTA .3gp VLC.3gp
    SetUserFTA .3gp2 VLC.3gp2
    SetUserFTA .3gpp VLC.3gpp
    SetUserFTA .aac VLC.aac
    SetUserFTA .ac3 VLC.ac3
    SetUserFTA .adt VLC.adt
    SetUserFTA .adts VLC.adts
    SetUserFTA .amr VLC.amr
    SetUserFTA .arw IrfanView.arw
    SetUserFTA .asf VLC.asf
    SetUserFTA .avi VLC.avi
    SetUserFTA .bmp IrfanView.bmp
    SetUserFTA .cr2 IrfanView.cr2
    SetUserFTA .crw IrfanView.crw
    SetUserFTA .dib IrfanView.dib
    SetUserFTA .divx VLC.divx
    SetUserFTA .ec3 VLC.ec3
    SetUserFTA .erf IrfanView.erf
    SetUserFTA .flac VLC.flac
    SetUserFTA .ftp ChromeHTML
    SetUserFTA .gif IrfanView.gif
    SetUserFTA .heic IrfanView.heic
    SetUserFTA .htm ChromeHTML
    SetUserFTA .html ChromeHTML
    SetUserFTA .ico IrfanView.ico
    SetUserFTA .jfif IrfanView.jfif
    SetUserFTA .jpe IrfanView.jpe
    SetUserFTA .jpeg IrfanView.jpg
    SetUserFTA .jpg IrfanView.jpg
    SetUserFTA .jxr IrfanView.jxr
    SetUserFTA .kdc IrfanView.kdc
    SetUserFTA .log Applications\notepad++.exe
    SetUserFTA .m1v VLC.m1v
    SetUserFTA .m2t VLC.m2t
    SetUserFTA .m2ts VLC.m2ts
    SetUserFTA .m2v VLC.m2v
    SetUserFTA .m3u VLC.m3u
    SetUserFTA .m4a VLC.m4a
    SetUserFTA .m4r VLC.m4r
    SetUserFTA .m4v VLC.m4v
    SetUserFTA .mht ChromeHTML
    SetUserFTA .mhtml ChromeHTML
    SetUserFTA .mka VLC.mka
    SetUserFTA .mkv VLC.mkv
    SetUserFTA .mod VLC.mod
    SetUserFTA .mov VLC.mov
    SetUserFTA .MP2 VLC.MP2
    SetUserFTA .mp2v VLC.mp2v
    SetUserFTA .mp3 VLC.mp3
    SetUserFTA .mp4 VLC.mp4
    SetUserFTA .mp4v VLC.mp4v
    SetUserFTA .mpa VLC.mpa
    SetUserFTA .MPE VLC.MPE
    SetUserFTA .mpeg VLC.mpeg
    SetUserFTA .mpg VLC.mpg
    SetUserFTA .mpv2 VLC.mpv2
    SetUserFTA .mrw IrfanView.mrw
    SetUserFTA .mts VLC.mts
    SetUserFTA .nef IrfanView.nef
    SetUserFTA .nrw IrfanView.nrw
    SetUserFTA .oga VLC.oga
    SetUserFTA .ogg VLC.ogg
    SetUserFTA .ogm VLC.ogm
    SetUserFTA .ogv VLC.ogv
    SetUserFTA .ogx VLC.ogx
    SetUserFTA .opus VLC.opus
    SetUserFTA .orf IrfanView.orf
    SetUserFTA .pdf FoxitReader.Document
    SetUserFTA .pef IrfanView.pef
    SetUserFTA .png IrfanView.pngz
    SetUserFTA .raf IrfanView.raf
    SetUserFTA .raw IrfanView.raw
    SetUserFTA .rw2 IrfanView.rw2
    SetUserFTA .rwl IrfanView.rwl
    SetUserFTA .shtml ChromeHTML
    SetUserFTA .sr2 IrfanView.sr2
    SetUserFTA .srw IrfanView.srw
    SetUserFTA .svg ChromeHTML
    SetUserFTA .tif IrfanView.tif
    SetUserFTA .tiff IrfanView.tiff
    SetUserFTA .tod VLC.tod
    SetUserFTA .TS VLC.TS
    SetUserFTA .TTS VLC.TTS
    SetUserFTA .txt Applications\notepad++.exe
    SetUserFTA .wav VLC.wav
    SetUserFTA .wdp IrfanView.wdp
    SetUserFTA .webm VLC.webm
    SetUserFTA .webp ChromeHTML
    SetUserFTA .wm VLC.wm
    SetUserFTA .wma VLC.wma
    SetUserFTA .wmv VLC.wmv
    SetUserFTA .WPL VLC.WPL
    SetUserFTA .xht ChromeHTML
    SetUserFTA .xhtml ChromeHTML
    SetUserFTA .xvid VLC.xvid
    SetUserFTA .zpl VLC.zpl
    SetUserFTA ftp ChromeHTML
    SetUserFTA http ChromeHTML
    SetUserFTA https ChromeHTML
    SetUserFTA mailto ChromeHTML
    SetUserFTA microsoft-edge ChromeHTML
    SetUserFTA microsoft-edge-holographic ChromeHTML
    SetUserFTA ms-xbl-3d8b930f ChromeHTML
    SetUserFTA read ChromeHTML
    echo Default program associations updated.
    :: Incrementing history
    reg add "HKCU\Software\Windows_setup_script" /v Windows_setup_script_execution_state /t REG_DWORD /d 5 /f >nul 2>&1
    call :Update_local_run_history
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
    :: Incrementing history
    reg add "HKCU\Software\Windows_setup_script" /v Windows_setup_script_execution_state /t REG_DWORD /d 6 /f >nul 2>&1
    call :Update_local_run_history
    goto :EOF

:Task7
    echo Task 7 is executing...
    :: Update all Microsoft Store apps
    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-AppxPackage -AllUsers | Where-Object { $_.PublisherId -like '*Microsoft*'} | Foreach { Add-AppxPackage -DisableDevelopmentMode -Register ""$($_.InstallLocation)\AppXManifest.xml"" }"
    echo Microsoft Store apps updated.
    :: Incrementing history
    reg add "HKCU\Software\Windows_setup_script" /v Windows_setup_script_execution_state /t REG_DWORD /d 7 /f >nul 2>&1
    call :Update_local_run_history
    goto :EOF

:Task8
    echo Task 8 is executing...
    :: Remove all shortcuts from the desktop
    del /q %userprofile%\Desktop\*.lnk
    echo All shortcuts removed from the desktop.
    :: Incrementing history
    reg add "HKCU\Software\Windows_setup_script" /v Windows_setup_script_execution_state /t REG_DWORD /d 8 /f >nul 2>&1
    call :Update_local_run_history
    goto :EOF

:Task9
    echo Task 9 is executing...
    :: Uninstall junk Windows Store apps
    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-AppxPackage -AllUsers | Where-Object { $_.Name -in @('MicrosoftStickyNotes', 'Microsoft.MSnWeather', 'MicrosoftSolitaireCollection', 'Microsoft.ChimpChamp', 'Microsoft.ZuneMusic', 'Microsoft.WindowsSnippingTool', 'Microsoft.BingNews', 'Microsoft.WindowsSoundRecorder', 'Microsoft.PowerAutomateDesktop', 'MicrosoftTeams', 'Skype', 'OneDrive') } | Remove-AppxPackage -ErrorAction SilentlyContinue"
    echo Junk apps uninstalled.
    :: Incrementing history
    reg add "HKCU\Software\Windows_setup_script" /v Windows_setup_script_execution_state /t REG_DWORD /d 9 /f >nul 2>&1
    call :Update_local_run_history
    goto :EOF
