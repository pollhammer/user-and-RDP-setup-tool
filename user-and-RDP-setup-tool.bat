@echo off
REM written by Manuel Pollhammer
setlocal

REM Titel des Fensters setzen
title Benutzer- und RDP-Setup-Tool

echo ================================
echo  Benutzer- und RDP-Setup-Tool
echo ================================
echo.

REM Benutzereingaben abfragen
set /p username="Bitte geben Sie den neuen Benutzernamen ein: "
set /p password="Bitte geben Sie das Passwort für den neuen Benutzer ein: "

REM Benutzer erstellen
echo Erstelle Benutzer "%username%"...
net user %username% %password% /add

REM Überprüfen, ob der Benutzer erfolgreich erstellt wurde
if %errorlevel% neq 0 (
    echo Fehler beim Erstellen des Benutzers "%username%". Bitte überprüfen Sie Ihre Eingaben und versuchen Sie es erneut.
    goto End
)

REM Benutzer zur Administratorgruppe hinzufügen
echo Füge Benutzer "%username%" zur Administratorgruppe hinzu...
net localgroup Administrators %username% /add

REM Überprüfen, ob der Benutzer erfolgreich zur Administratorgruppe hinzugefügt wurde
if %errorlevel% neq 0 (
    echo Fehler beim Hinzufügen des Benutzers "%username%" zur Administratorgruppe. Bitte überprüfen Sie Ihre Eingaben und versuchen Sie es erneut.
    goto End
)

REM RDP aktivieren
echo Überprüfe, ob RDP aktiviert ist...
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections | findstr /C:"0x0"
if %errorlevel% neq 0 (
    echo RDP ist derzeit deaktiviert. Aktivieren...
    reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f
    echo RDP wurde aktiviert.
) else (
    echo RDP ist bereits aktiviert.
)

REM RDP für den neuen Benutzer aktivieren
echo Gewähre dem Benutzer "%username%" RDP-Zugriff...
echo %username% >> "%temp%\rdp_users.txt"
powershell -Command "Add-LocalGroupMember -Group 'Remote Desktop Users' -Member '%username%'"

REM Überprüfen, ob der Benutzer erfolgreich zur Gruppe hinzugefügt wurde
if %errorlevel% neq 0 (
    echo Fehler beim Gewähren des RDP-Zugriffs für den Benutzer "%username%". Bitte überprüfen Sie Ihre Eingaben und versuchen Sie es erneut.
    goto End
)

echo Benutzer "%username%" wurde erfolgreich erstellt, hat Administratorrechte und RDP-Zugriff erhalten.
echo.
echo Drücken Sie eine beliebige Taste zum Beenden...
pause >nul

:End
endlocal
