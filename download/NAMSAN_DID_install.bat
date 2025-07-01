@echo off
setlocal enableDelayedExpansion

REM -----------------------------------------------------
REM 1. URL 선택 메뉴
REM -----------------------------------------------------
:SELECT_URL
cls
echo ===================================================
echo   Chrome Kiosk 모드 자동 실행 URL 선택
echo ===================================================
echo.
echo 1번 (1,2층)   : http://wizinfo.iptime.org:8080/index1.php
echo 2번 (매표할인) : http://wizinfo.iptime.org:8080/index2.php
echo 3번 (매표유의) : http://wizinfo.iptime.org:8080/index3.php
echo 4번 (매표요금) : http://wizinfo.iptime.org:8080/index4.php
echo.
set /p "CHOICE=자동 실행할 URL 번호를 입력하세요 (1-4): "

set "SELECTED_URL="
if "%CHOICE%"=="1" set "SELECTED_URL=http://wizinfo.iptime.org:8080/index1.php"
if "%CHOICE%"=="2" set "SELECTED_URL=http://wizinfo.iptime.org:8080/index2.php"
if "%CHOICE%"=="3" set "SELECTED_URL=http://wizinfo.iptime.org:8080/index3.php"
if "%CHOICE%"=="4" set "SELECTED_URL=http://wizinfo.iptime.org:8080/index4.php"

if not defined SELECTED_URL (
    echo.
    echo 잘못된 입력입니다. 1에서 4 사이의 숫자를 입력해주세요.
    timeout /t 2 >nul
    goto :SELECT_URL
)

echo.
echo 선택된 URL: %SELECTED_URL%
echo.

REM -----------------------------------------------------
REM 2. 자동 실행될 BAT 파일 생성 (start_kiosk.bat)
REM -----------------------------------------------------
set "KIOSK_BAT_FILENAME=start_kiosk.bat"
set "KIOSK_BAT_PATH=%~dp0%KIOSK_BAT_FILENAME%" REM 이 스크립트와 동일한 폴더에 생성

echo @echo off > "%KIOSK_BAT_PATH%"
echo start "" "chrome.exe" --kiosk %SELECTED_URL% >> "%KIOSK_BAT_PATH%"
echo echo Chrome Kiosk 모드 시작됨. >> "%KIOSK_BAT_PATH%"
echo exit >> "%KIOSK_BAT_PATH%"

if exist "%KIOSK_BAT_PATH%" (
    echo "%KIOSK_BAT_FILENAME%" 파일이 성공적으로 생성되었습니다:
    echo %KIOSK_BAT_PATH%
) else (
    echo 오류: "%KIOSK_BAT_FILENAME%" 파일 생성에 실패했습니다.
    pause
    goto :eof
)

echo.

REM -----------------------------------------------------
REM 3. 생성된 BAT 파일을 작업 스케줄러에 등록 (부팅 시 자동 실행)
REM -----------------------------------------------------
set "TASK_NAME_KIOSK=StartChromeKioskOnBoot"
set "DESCRIPTION_KIOSK=Start Chrome in Kiosk mode on Windows boot with selected URL."

REM 기존 작업이 있다면 삭제 (선택 사항 - 중복 방지)
schtasks /delete /tn "%TASK_NAME_KIOSK%" /f >nul 2>&1

REM 작업 스케줄러에 새 작업 생성
schtasks /create /tn "%TASK_NAME_KIOSK%" /tr "\"%KIOSK_BAT_PATH%\"" /sc ONSTART /ru SYSTEM /f /RL HIGHEST

if %errorlevel% equ 0 (
    echo 작업 스케줄 "%TASK_NAME_KIOSK%"가 성공적으로 추가되었습니다.
    echo 윈도우 부팅 시 Chrome Kiosk 모드가 자동으로 시작됩니다.
) else (
    echo 오류: 작업 스케줄 "%TASK_NAME_KIOSK%" 추가에 실패했습니다. 오류 코드: %errorlevel%
    echo 관리자 권한으로 이 스크립트를 실행했는지 확인해주세요.
    pause
    goto :eof
)

echo.
echo -----------------------------------------------------
echo   자동 종료 스케줄 설정
echo -----------------------------------------------------
:GET_SHUTDOWN_TIME
set /p "SHUTDOWN_TIME_INPUT=매일 자동 종료할 시간을 HH:MM 형식으로 입력하세요 (예: 23:30): "

echo %SHUTDOWN_TIME_INPUT% | findstr /r "^[0-2][0-9]:[0-5][0-9]$" >nul
if %errorlevel% neq 0 (
    echo.
    echo 잘못된 시간 형식입니다. HH:MM 형식으로 다시 입력해주세요.
    timeout /t 2 >nul
    goto :GET_SHUTDOWN_TIME
)

set "SHUTDOWN_HOUR=%SHUTDOWN_TIME_INPUT:~0,2%"
set "SHUTDOWN_MINUTE=%SHUTDOWN_TIME_INPUT:~3,2%"

if %SHUTDOWN_HOUR% geq 24 (
    echo.
    echo 시간(HH)은 00부터 23까지의 값이어야 합니다.
    timeout /t 2 >nul
    goto :GET_SHUTDOWN_TIME
)

REM -----------------------------------------------------
REM 4. 자동 종료 스케줄 추가
REM -----------------------------------------------------
set "TASK_NAME_SHUTDOWN=AutoShutdownDaily"

REM 기존 작업이 있다면 삭제 (선택 사항 - 중복 방지)
schtasks /delete /tn "%TASK_NAME_SHUTDOWN%" /f >nul 2>&1

REM 매일 지정된 시간에 컴퓨터 종료 작업 추가
schtasks /create /tn "%TASK_NAME_SHUTDOWN%" /tr "shutdown /s /f /t 0" /sc daily /st "%SHUTDOWN_TIME_INPUT%" /f

if %errorlevel% equ 0 (
    echo.
    echo 작업 스케줄 "%TASK_NAME_SHUTDOWN%"가 성공적으로 추가되었습니다.
    echo 매일 %SHUTDOWN_TIME_INPUT% 에 컴퓨터가 종료됩니다.
) else (
    echo.
    echo 작업 스케줄 "%TASK_NAME_SHUTDOWN%" 추가에 실패했습니다. 오류 코드: %errorlevel%
    echo 관리자 권한으로 이 스크립트를 실행했는지 확인해주세요.
)

echo.
echo 모든 설정이 완료되었습니다.
echo.
echo 참고: Chrome이 설치된 경로가 시스템 PATH에 없으면 'chrome.exe'를 찾지 못할 수 있습니다.
echo 그 경우, "%KIOSK_BAT_PATH%" 파일을 열어 'chrome.exe'를 Chrome이 설치된 전체 경로로 변경해야 합니다.
echo 예: "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
echo.
pause
endlocal