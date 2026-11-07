@echo off
setlocal
REM Turns Citrix App Protection back ON (original start types) for work.
REM Tries to start the drivers live; only asks for a restart if Windows refuses.
REM Double-click it; it asks for administrator rights itself.

net session >nul 2>&1
if errorlevel 1 (
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b 0
)

echo Restoring App Protection start settings...
sc config ctxapinject start= system >nul || goto :failed
sc config ctxapdriver start= auto >nul || goto :failed

echo Closing Citrix Workspace if open...
for %%p in (SelfServicePlugin Receiver wfcrun32 concentr redirector AuthManSvr AnalyticsSrv) do taskkill /f /im %%p.exe >nul 2>&1

echo Starting App Protection drivers...
sc start ctxapdriver >nul 2>&1
sc start ctxapinject >nul 2>&1
call :waitstate ctxapdriver RUNNING
if errorlevel 1 goto :needrestart
call :waitstate ctxapinject RUNNING
if errorlevel 1 goto :needrestart

echo.
echo Done - App Protection is ON now, no restart needed.
echo Start Citrix Workspace again. Programs opened from now on are protected.
echo For full protection of everything already open, a restart is still the safest.
pause
exit /b 0

:needrestart
echo.
echo Windows would not start the drivers live. They are set to start after a restart.
choice /c YN /m "Restart now"
if errorlevel 2 exit /b 0
shutdown /r /t 0
exit /b 0

:failed
echo.
echo FAILED to change a driver. Use regedit instead:
echo HKLM\SYSTEM\CurrentControlSet\Services\ctxapinject  Start = 1
echo HKLM\SYSTEM\CurrentControlSet\Services\ctxapdriver  Start = 2
pause
exit /b 1

REM Waits up to ~10s for service %1 to reach state %2. errorlevel 0 = reached.
:waitstate
for /l %%i in (1,1,10) do (
    sc query %1 | findstr /c:"%2" >nul && exit /b 0
    timeout /t 1 /nobreak >nul
)
exit /b 1
