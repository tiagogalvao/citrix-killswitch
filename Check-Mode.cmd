@echo off
REM Shows whether Citrix App Protection is currently ON (work) or OFF (game)

for /f "tokens=3" %%s in ('sc qc ctxapinject ^| findstr /c:"START_TYPE"') do set START=%%s
for /f "tokens=4" %%s in ('sc query ctxapinject ^| findstr /c:"STATE"') do set STATE=%%s

echo ctxapinject start type: %START%   state: %STATE%
echo.
if "%STATE%"=="RUNNING" (
    echo App Protection is ON  - Work mode.
) else (
    echo App Protection is OFF - Game mode. Run Work-Mode before working.
)
if "%START%"=="4" if "%STATE%"=="RUNNING" echo Game mode is set but the driver is still running - restart to finish.
if not "%START%"=="4" if not "%STATE%"=="RUNNING" echo Work mode is set but the driver is not running - run Work-Mode again or restart.
echo.
pause
