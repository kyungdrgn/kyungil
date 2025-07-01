@echo off
setlocal enableDelayedExpansion

REM -----------------------------------------------------
REM 1. URL ���� �޴�
REM -----------------------------------------------------
:SELECT_URL
cls
echo ===================================================
echo   Chrome Kiosk ��� �ڵ� ���� URL ����
echo ===================================================
echo.
echo 1�� (1,2��)   : http://wizinfo.iptime.org:8080/index1.php
echo 2�� (��ǥ����) : http://wizinfo.iptime.org:8080/index2.php
echo 3�� (��ǥ����) : http://wizinfo.iptime.org:8080/index3.php
echo 4�� (��ǥ���) : http://wizinfo.iptime.org:8080/index4.php
echo.
set /p "CHOICE=�ڵ� ������ URL ��ȣ�� �Է��ϼ��� (1-4): "

set "SELECTED_URL="
if "%CHOICE%"=="1" set "SELECTED_URL=http://wizinfo.iptime.org:8080/index1.php"
if "%CHOICE%"=="2" set "SELECTED_URL=http://wizinfo.iptime.org:8080/index2.php"
if "%CHOICE%"=="3" set "SELECTED_URL=http://wizinfo.iptime.org:8080/index3.php"
if "%CHOICE%"=="4" set "SELECTED_URL=http://wizinfo.iptime.org:8080/index4.php"

if not defined SELECTED_URL (
    echo.
    echo �߸��� �Է��Դϴ�. 1���� 4 ������ ���ڸ� �Է����ּ���.
    timeout /t 2 >nul
    goto :SELECT_URL
)

echo.
echo ���õ� URL: %SELECTED_URL%
echo.

REM -----------------------------------------------------
REM 2. �ڵ� ����� BAT ���� ���� (start_kiosk.bat)
REM -----------------------------------------------------
set "KIOSK_BAT_FILENAME=start_kiosk.bat"
set "KIOSK_BAT_PATH=%~dp0%KIOSK_BAT_FILENAME%" REM �� ��ũ��Ʈ�� ������ ������ ����

echo @echo off > "%KIOSK_BAT_PATH%"
echo start "" "chrome.exe" --kiosk %SELECTED_URL% >> "%KIOSK_BAT_PATH%"
echo echo Chrome Kiosk ��� ���۵�. >> "%KIOSK_BAT_PATH%"
echo exit >> "%KIOSK_BAT_PATH%"

if exist "%KIOSK_BAT_PATH%" (
    echo "%KIOSK_BAT_FILENAME%" ������ ���������� �����Ǿ����ϴ�:
    echo %KIOSK_BAT_PATH%
) else (
    echo ����: "%KIOSK_BAT_FILENAME%" ���� ������ �����߽��ϴ�.
    pause
    goto :eof
)

echo.

REM -----------------------------------------------------
REM 3. ������ BAT ������ �۾� �����ٷ��� ��� (���� �� �ڵ� ����)
REM -----------------------------------------------------
set "TASK_NAME_KIOSK=StartChromeKioskOnBoot"
set "DESCRIPTION_KIOSK=Start Chrome in Kiosk mode on Windows boot with selected URL."

REM ���� �۾��� �ִٸ� ���� (���� ���� - �ߺ� ����)
schtasks /delete /tn "%TASK_NAME_KIOSK%" /f >nul 2>&1

REM �۾� �����ٷ��� �� �۾� ����
schtasks /create /tn "%TASK_NAME_KIOSK%" /tr "\"%KIOSK_BAT_PATH%\"" /sc ONSTART /ru SYSTEM /f /RL HIGHEST

if %errorlevel% equ 0 (
    echo �۾� ������ "%TASK_NAME_KIOSK%"�� ���������� �߰��Ǿ����ϴ�.
    echo ������ ���� �� Chrome Kiosk ��尡 �ڵ����� ���۵˴ϴ�.
) else (
    echo ����: �۾� ������ "%TASK_NAME_KIOSK%" �߰��� �����߽��ϴ�. ���� �ڵ�: %errorlevel%
    echo ������ �������� �� ��ũ��Ʈ�� �����ߴ��� Ȯ�����ּ���.
    pause
    goto :eof
)

echo.
echo -----------------------------------------------------
echo   �ڵ� ���� ������ ����
echo -----------------------------------------------------
:GET_SHUTDOWN_TIME
set /p "SHUTDOWN_TIME_INPUT=���� �ڵ� ������ �ð��� HH:MM �������� �Է��ϼ��� (��: 23:30): "

echo %SHUTDOWN_TIME_INPUT% | findstr /r "^[0-2][0-9]:[0-5][0-9]$" >nul
if %errorlevel% neq 0 (
    echo.
    echo �߸��� �ð� �����Դϴ�. HH:MM �������� �ٽ� �Է����ּ���.
    timeout /t 2 >nul
    goto :GET_SHUTDOWN_TIME
)

set "SHUTDOWN_HOUR=%SHUTDOWN_TIME_INPUT:~0,2%"
set "SHUTDOWN_MINUTE=%SHUTDOWN_TIME_INPUT:~3,2%"

if %SHUTDOWN_HOUR% geq 24 (
    echo.
    echo �ð�(HH)�� 00���� 23������ ���̾�� �մϴ�.
    timeout /t 2 >nul
    goto :GET_SHUTDOWN_TIME
)

REM -----------------------------------------------------
REM 4. �ڵ� ���� ������ �߰�
REM -----------------------------------------------------
set "TASK_NAME_SHUTDOWN=AutoShutdownDaily"

REM ���� �۾��� �ִٸ� ���� (���� ���� - �ߺ� ����)
schtasks /delete /tn "%TASK_NAME_SHUTDOWN%" /f >nul 2>&1

REM ���� ������ �ð��� ��ǻ�� ���� �۾� �߰�
schtasks /create /tn "%TASK_NAME_SHUTDOWN%" /tr "shutdown /s /f /t 0" /sc daily /st "%SHUTDOWN_TIME_INPUT%" /f

if %errorlevel% equ 0 (
    echo.
    echo �۾� ������ "%TASK_NAME_SHUTDOWN%"�� ���������� �߰��Ǿ����ϴ�.
    echo ���� %SHUTDOWN_TIME_INPUT% �� ��ǻ�Ͱ� ����˴ϴ�.
) else (
    echo.
    echo �۾� ������ "%TASK_NAME_SHUTDOWN%" �߰��� �����߽��ϴ�. ���� �ڵ�: %errorlevel%
    echo ������ �������� �� ��ũ��Ʈ�� �����ߴ��� Ȯ�����ּ���.
)

echo.
echo ��� ������ �Ϸ�Ǿ����ϴ�.
echo.
echo ����: Chrome�� ��ġ�� ��ΰ� �ý��� PATH�� ������ 'chrome.exe'�� ã�� ���� �� �ֽ��ϴ�.
echo �� ���, "%KIOSK_BAT_PATH%" ������ ���� 'chrome.exe'�� Chrome�� ��ġ�� ��ü ��η� �����ؾ� �մϴ�.
echo ��: "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
echo.
pause
endlocal