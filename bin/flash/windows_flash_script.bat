@echo off
cls
setlocal enabledelayedexpansion
reg query "HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\Nls\Language" /v InstallLanguage|find "0804">nul&& set LANG=Chinese
if "%LANG%"=="Chinese" (
    TITLE windows ˢ���ű� [����ѡ�д��ڣ���ס���Ҽ���س���Ŵ���С���ڻָ�]
) else (
    TITLE Windows Flash Script
)
color 3f
echo.
if exist "super.zst" (
    if "%LANG%"=="Chinese" (
        echo. ���ڽ�ѹsuper����,���ĵȴ�
    ) else (
        echo. Extracting the super image, wait patiently
    )
    platform-tools-windows\zstd.exe --rm -d super.zst -o super.img
    if not "%errorlevel%" == "0" (
        if "%LANG%"=="Chinese" (
            echo. ת��ʧ��,��������˳�
        ) else (
            echo. Conversion failed. Press any key to exit
        )
        pause >nul 2>nul
        exit
    )
)

if "%LANG%"=="Chinese" (
    echo.
    echo. 1. ��������ˢ��
    echo.
    echo. 2. ˫��ˢ��
    echo.
    set /p input=��ѡ��-Ĭ��ѡ��1,�س�ִ��:
) else (
    echo.
    echo. 1. Preserve user data during flashing
    echo.
    echo. 2. Wiping data without wiping /data/media
    echo.
    set /p input=Please select - 1 is selected by default, and enter to execute:
)

if "%LANG%"=="Chinese" (
    echo.
    echo. ������֤��...��ȷ�������豸����Ϊdevice_code�����Ѿ�����fastbootdģʽ adb reboot fastboot��

    echo.
) else (
    echo.
    echo. Validating device...please boot your device into bootloader and make sure your device code is device_code
    echo.
)

:: ��ȡ�豸����
for /f "tokens=2 delims=: " %%i in ('fastboot %* getvar product 2^>^&1 ^| findstr /r /c:"^product: "') do set "product=%%i"

:: Ԥ���豸����
set "expected_device=device_code"

:: ����������ص���Ϣ
if "%LANG%"=="Chinese" (
    set "msg_mismatch= �豸device_code��ƥ�䡣�����Ƿ��ǽ���fastbootdģʽ"
    set "msg_continue=���������(y/n): "
    set "msg_abort= �����ѱ��û���ֹ��"
    set "msg_continue_process=��������..."
) else (
    set "msg_mismatch=Mismatching image and device."
    set "msg_continue=Do you want to continue anyway? (y/n): "
    set "msg_abort=Operation aborted by user."
    set "msg_continue_process=Continuing with the process..."
)

:: ����Ƿ�ƥ��
if /i "!product!" neq "%expected_device%" (
    echo %msg_mismatch%
    set /p "choice=%msg_continue%"
    if /i "!choice!" neq "y" (
        echo %msg_abort%
        exit /B 1
    )
)

if "%LANG%"=="Chinese" (
    echo.
    echo. 1. ˢ��KSU�ں�
    echo.
    echo. 2. ˢ��ٷ��ں�
    echo.
    set /p kernel=��ѡ��-Ĭ��ѡ��1,�س�ִ��:
) else (
    echo.
    echo. 1. Flashing KernelSU boot.img
    echo.
    echo. 2. Flashing Official boot.img
    echo.
    set /p kernel=Please select - 1 is selected by default, and enter to execute:
)

if  "%kernel%"=="1" (
    if "%LANG%"=="Chinese" (
	    echo. ˢ�������boot_ksu.img
        
    ) else (
        echo. Flashing custom boot.img
    ) 
    platform-tools-windows\fastboot.exe flash boot %~dp0boot_ksu.img
    platform-tools-windows\fastboot.exe flash dtbo %~dp0firmware-update/dtbo_ksu.img

) else (
    platform-tools-windows\fastboot.exe flash boot %~dp0boot_official.img
    platform-tools-windows\fastboot.exe flash dtbo %~dp0firmware-update/dtbo.img
)

REM firmware

platform-tools-windows\fastboot.exe erase super
platform-tools-windows\fastboot.exe reboot bootloader
ping 127.0.0.1 -n 5 >nul 2>nul
platform-tools-windows\fastboot.exe flash super %~dp0super.img
if "%input%" == "2" (
	if "%LANG%"=="Chinese" (
	    echo. ����˫��ϵͳ,���ĵȴ�
    ) else (
        echo. Wiping data without wiping /data/media/, please wait patiently
    ) 
	platform-tools-windows\fastboot.exe erase userdata
	platform-tools-windows\fastboot.exe erase metadata
)
REM SET_ACTION_SLOT_A_BEGIN
if "%LANG%"=="Chinese" (
	echo. ���û����Ϊ 'a'��������ҪһЩʱ�䡣�����ֶ�����������ε������ߣ�������ܵ����豸��ש��
) else (
    echo. Starting the process to set the active slot to 'a.' This may take some time. Please refrain from manually restarting or unplugging the data cable, as doing so could result in the device becoming unresponsive.
)
platform-tools-windows\fastboot.exe set_active a

REM SET_ACTION_SLOT_A_END

platform-tools-windows\fastboot.exe reboot

if "%LANG%"=="Chinese" (
    echo. ˢ�����,���ֻ���ʱ��δ�������ֶ�����,��������˳�
) else (
    echo. Flash completed. If the phone does not restart for an extended period, please manually restart. Press any key to exit.
)
pause
exit
