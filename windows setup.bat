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
	start explorer.bat
)

:programs_install
call :MsgBox "Install basic programs?"  "VBYesNo+VBQuestion" "Question"
if errorlevel 7 (
	echo Programs will not be installed!
) else if errorlevel 6 (
	echo Installing basic sofware...
	start ChromeSetup.exe & pause
	start iview.exe & pause
	start vlc.exe & pause
	start FoxitPDFReader.exe & pause
)

:taskbar_setup
call :MsgBox "Set up taskbar?"  "VBYesNo+VBQuestion" "Question"
if errorlevel 7 (
	echo Taskbar stays as is!
) else if errorlevel 6 (
	Reg.exe add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "SearchboxTaskbarMode" /t REG_DWORD /d "0" /f
	REM Cortana
	REM icons setup
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