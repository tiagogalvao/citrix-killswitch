@echo off
setlocal
REM Turns Citrix App Protection OFF.
REM Tries to stop the drivers live.

net session >nul 2>&1
if errorlevel 1 (
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b 0
)

echo This closes Citrix Workspace. Save and close any work session first.
choice /c YN /m "Continue"
if errorlevel 2 exit /b 0

echo.
echo Keeping App Protection off across restarts...
sc config ctxapinject start= disabled >nul || goto :failed
sc config ctxapdriver start= disabled >nul || goto :failed

echo Closing Citrix Workspace...
for %%p in (SelfServicePlugin Receiver wfcrun32 concentr redirector AuthManSvr AnalyticsSrv) do taskkill /f /im %%p.exe >nul 2>&1

echo Stopping App Protection drivers...
sc stop ctxapinject >nul 2>&1
sc stop ctxapdriver >nul 2>&1
call :waitstate ctxapinject STOPPED
if errorlevel 1 goto :needrestart
call :waitstate ctxapdriver STOPPED
if errorlevel 1 goto :needrestart

echo.
echo Done - App Protection is OFF now, no restart needed.
echo Programs opened before this point still carry the Citrix DLL; new ones will not.
echo Run Work-Mode before you work.
pause
exit /b 0

:needrestart
echo.
echo Windows would not stop the drivers live. They are set to stay off after a restart.
choice /c YN /m "Restart now"
if errorlevel 2 exit /b 0
shutdown /r /t 0
exit /b 0

:failed
echo.
echo FAILED to change a driver. If it says "Access is denied", Citrix is protecting it;
echo use regedit instead: HKLM\SYSTEM\CurrentControlSet\Services\ctxapinject and \ctxapdriver, set Start = 4.
pause
exit /b 1

REM Waits up to ~10s for service %1 to reach state %2. errorlevel 0 = reached.
:waitstate
for /l %%i in (1,1,10) do (
    sc query %1 | findstr /c:"%2" >nul && exit /b 0
    timeout /t 1 /nobreak >nul
)
exit /b 1
