@echo off

REM ------------------------------------------------------------------------------
REM
REM This is the `git-subrepo` cmd initialization script.
REM
REM This script turns on the `git-subrepo` Git subcommand for Windows command-line
REM
REM Just execute inside cmd.exe or another batch file:
REM
REM   path\to\git-subrepo\activate.bat
REM
REM ------------------------------------------------------------------------------


where git.exe >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo could not find git in PATH
    goto:end
)

if NOT "%GIT_SUBREPO_ROOT%" == "%~dp0" (
    set "GIT_SUBREPO_ROOT=%~dp0"
    set "PATH=%~dp0lib;%PATH%"
)
for /F "tokens=* USEBACKQ" %%F IN (`git subrepo --version`) do (
    echo using version %%F in %GIT_SUBREPO_ROOT%
)

:end
