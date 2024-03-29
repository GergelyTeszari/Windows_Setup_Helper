@echo off

set win_ver=0
set run_history=0
set history_file_name=WSH.kredenc

:: Administrator privileges check
>nul 2>&1 "%SYSTEMROOT%\System32\cacls.exe" "%SYSTEMROOT%\System32\config\system"
if %errorlevel%==0 (
    echo Admin privileges granted.
    :: Tasks call
    call :Windows_version_check
    call :Check_for_previous_runs
    if %run_history%==0 (
        call :Task1 :: Creating performance power plan, turning on game mode
    ) else if %run_history%==1 (
        call :Check_for_internet_connection
        call :Task2 :: Installing Chocolatey
    ) else if %run_history%==2 (
        call :Check_for_internet_connection
        call :Task3 :: Installing programs via Chocolatey        
    ) else if %run_history%==3 (
        call :Task4 :: Resetting Windows Photos and Movies & TV        
    ) else if %run_history%==4 (
        call :Task5 :: Setting default file associations
    ) else if %run_history%==5 (
        call :Task6 :: Applying aesthetic modifications
    ) else if %run_history%==6 (
        call :Check_for_internet_connection
        call :Task7 :: Updating Store apps
    ) else if %run_history%==7 (
        call :Task8 :: Removing shortcuts from desktop
    ) else if %run_history%==8 (
        call :Task9 :: Uninstall junk Windows Store apps
    ) else if %run_history%==9 (
        call Task10 :: Update all drivers
    ) else if %run_history%==10 (
        call Task11 :: UNINPLEMENTED
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

:: History related functions

:Check_for_previous_runs
	cd %USERPROFILE%
	if exist %history_file_name% (
		echo Run history found.
        call :Load_local_run_history
        echo Restored to local variable: %run_history%
        goto :EOF
    ) else (
        echo Run history not found.
        call :Create_run_history
        goto :EOF
    )

:Create_run_history
	cd %USERPROFILE%
    echo Creating run history...
	echo >%history_file_name%
    echo created empty run history.
    goto :EOF

:Load_local_run_history
    echo Querying data from history storage file...
	cd %USERPROFILE%
	for /f "usebackq delims=" %%a in ("%history_file_name%") do (
    set "run_history=%%a"
	echo Loaded value: %run_history%
    goto :EOF

:Push_local_run_history
	echo Writing run history to the storage file...
	cd %USERPROFILE%
	if exist %history_file_name% (
		del %history_file_name%
	)
	echo %run_history% > %history_file_name%
	echo File write successfully finished.
	goto :EOF

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
    :: Incrementing history
	%run_history%=1
    call :Push_local_run_history
    goto :EOF

:Task2
    echo Task 2 is executing...
    :: Open a new PowerShell console with execution policy bypass
    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))"
    echo Chocolatey installed.
    :: Incrementing history
	%run_history%=2
    call :Push_local_run_history
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
	%run_history%=3
    call :Push_local_run_history
    goto :EOF

:Task4
    echo Task 4 is executing...
    :: Reset Windows Photos
    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-AppxPackage -Name Microsoft.Windows.Photos | Reset-AppxPackage"
    :: Reset Windows Movies & TV
    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-AppxPackage -Name Microsoft.ZuneVideo | Reset-AppxPackage"
    echo Windows Photos and Video app reset.
    :: Incrementing history
	%run_history%=4
    call :Push_local_run_history
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
    SetUserFTA .pdf ChromeHTML
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
	%run_history%=5
    call :Push_local_run_history
    goto :EOF

:Task6
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

:Task7
    echo Task 7 is executing...
    :: Update all Microsoft Store apps
    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "winget update --all --accept-source-agreements --accept-package-agreements"
    echo Microsoft Store apps updated.
    :: Update all apps using Chocolatey
    choco upgrade all -y
    :: Incrementing history
	%run_history%=7
    call :Push_local_run_history
    goto :EOF

:Task8
    echo Task 8 is executing...
    :: Remove all shortcuts from the desktop
    del /q %userprofile%\Desktop\*.lnk
    echo All shortcuts removed from the desktop.
    :: Incrementing history
	%run_history%=8
    call :Push_local_run_history
    goto :EOF

:Task9
    echo Task 9 is executing...
    :: Uninstall junk Windows Store apps
    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-AppxPackage -AllUsers | Where-Object { $_.Name -in @('MicrosoftStickyNotes', 'Microsoft.MSnWeather', 'MicrosoftSolitaireCollection', 'Microsoft.ChimpChamp', 'Microsoft.WindowsSnippingTool', 'Microsoft.BingNews', 'Microsoft.WindowsSoundRecorder', 'Microsoft.PowerAutomateDesktop', 'MicrosoftTeams', 'Skype', 'OneDrive') } | Remove-AppxPackage -ErrorAction SilentlyContinue"
    echo Junk apps uninstalled.
    :: Incrementing history
	%run_history%=9
    call :Push_local_run_history
    goto :EOF

:Task10 
	:: Not yet tested!
    echo Task 10 is executing...
	:: Installing Driverbooster
	choco install driverbooster -y
	echo If you completed the updating, press Enter to remove driver installer utility.
	cd "C:\Program Files (x86)\IObit\Driver Booster\11.2.0" & "Driver Booster 11.lnk"
	pause
	choco uninstall driverupdater -y
    :: Incrementing history
	%run_history%=10
    call :Push_local_run_history
    goto :EOF

:Task11
    echo Task 11 is executing...
    :: Incrementing history
	%run_history%=11
    call :Push_local_run_history
    goto :EOF
