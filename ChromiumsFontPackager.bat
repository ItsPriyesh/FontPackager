@echo off
title Chromium's Font Packager
mode con:cols=100 lines=50
color 0b
:: x variable default value of 0. For each of the 4 base fonts: if base font exists and the derivatives are created, update the value of x by adding 1. Therefore if x=4 at the end, all fonts have been created successfully.
set x=0

echo "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
echo "^                    ____ _                         _                 _                         ^"
echo "^                   / ___| |__  _ __ ___  _ __ ___ (_)_   _ _ __ ___ ( )___                     ^"
echo "^                  | |   | '_ \| '__/ _ \| '_ ` _ \| | | | | '_ ` _ \|// __|                    ^"
echo "^                  | |___| | | | | | (_) | | | | | | | |_| | | | | | | \__ \                    ^"
echo "^                 __\____|_| |_|_|_ \___/|_| |_| |_|_|\__,_|_| |_| |_| |___/                    ^"
echo "^                |  ___|__  _ __ | |_  |  _ \ __ _  ___| | ____ _  __ _  ___ _ __               ^"
echo "^                | |_ / _ \| '_ \| __| | |_) / _` |/ __| |/ / _` |/ _` |/ _ \ '__|              ^"
echo "^                |  _| (_) | | | | |_  |  __/ (_| | (__|   < (_| | (_| |  __/ |                 ^"
echo "^                |_|  \___/|_| |_|\__| |_|   \__,_|\___|_|\_\__,_|\__, |\___|_|                 ^"
echo "^                                                                 |___/                         ^"
echo "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
echo.

::Instructions
echo Requirements/Instructions: 
echo.
echo Put the 4 following files inside of the Input folder:
echo 	1. Roboto-Regular.ttf
echo 	2. Roboto-Italic.ttf
echo 	3. Roboto-Bold.ttf
echo 	4. Roboto-BoldItalic.tff
echo.
echo Once you have added the above files into the appropriate folder, press any key to begin . . .
pause >nul

::Get font name
echo.
set /p fontname=Please enter the name of the font without spaces: 

::Roboto-Regular derivatives
if exist Input\Roboto-Regular.ttf (
copy /y Input\Roboto-Regular.ttf RobotoCondensed-Regular.ttf >nul
copy /y Input\Roboto-Regular.ttf Roboto-Light.ttf >nul
copy /y Input\Roboto-Regular.ttf Roboto-Thin.ttf >nul
set /a x=1
)

::Roboto-Italic derivatives
if exist Input\Roboto-Italic.ttf (
copy /y Input\Roboto-Italic.ttf RobotoCondensed-Italic.ttf >nul
copy /y Input\Roboto-Italic.ttf Roboto-LightItalic.ttf >nul
copy /y Input\Roboto-Italic.ttf Roboto-ThinItalic.ttf >nul
set /a x=x+1
)

::Roboto-Bold derivatives
if exist Input\Roboto-Bold.ttf (
copy /y Input\Roboto-Bold.ttf RobotoCondensed-Bold.ttf >nul
set /a x=x+1
)

::Roboto-BoldItalic derivatives
if exist Input\Roboto-BoldItalic.ttf (
copy /y Input\Roboto-BoldItalic.ttf RobotoCondensed-BoldItalic.ttf >nul
set /a x=x+1
)

::Check to see if all fonts were created successfully
if %x% EQU 4 (
echo.
echo %fontname% font derivatives created successfully.
echo.
)

if %x% NEQ 4 (
echo.
echo Error - Aborting: fonts missing.
goto exitfail
)
 
::Create new directory and move fonts into it
mkdir fonts
move Input\Roboto-Regular.ttf fonts >nul
move Input\Roboto-Italic.ttf fonts >nul
move Input\Roboto-Bold.ttf fonts >nul
move Input\Roboto-BoldItalic.ttf fonts >nul
move Roboto-Light.ttf fonts >nul
move Roboto-LightItalic.ttf fonts >nul
move Roboto-Thin.ttf fonts >nul
move Roboto-ThinItalic.ttf fonts >nul
move RobotoCondensed-Regular.ttf fonts >nul
move RobotoCondensed-Italic.ttf fonts >nul
move RobotoCondensed-Bold.ttf fonts >nul
move RobotoCondensed-BoldItalic.ttf fonts >nul

::Create META-INF directory with subfolders
mkdir META-INF
cd META-INF
mkdir com
cd com
mkdir google
cd google
mkdir android
cd android

::Create updater-script
cd.>updater-script
echo ui_print("%fontname% - Font Pack");>updater-script
echo ui_print("Created using Chromium's Font Packager");>>updater-script
echo run_program("/sbin/busybox", "mount", "/system");>>updater-script
echo package_extract_dir("fonts", "/system/fonts");>>updater-script
echo run_program("/sbin/busybox", "umount", "/system");>>updater-script
echo ui_print("Font installation complete!");>>updater-script

::Create update-binary
::cd.>update-binary
cd..
cd..
cd..
cd..
::Back to root
copy bin\update-binary META-INF\com\google\android >nul

::Convert EOL from Windows to Unix (this prevents status 6 error when flashing)
bin\dos2unix META-INF\com\google\android\updater-script >nul

::Zip it all up
bin\7za a %fontname%FontPack.zip fonts META-INF >nul

::Move zip to out
move %fontname%FontPack.zip Output >nul
echo.
echo %fontname%FontPack.zip created successfully! It can be found in the Output folder.

echo.

echo Pick an installation method :
echo 1 - Copy flashable zip to phone then reboot phone into recovery.
echo 2 - Push font files directly into system then reboot phone.
echo 3 - Exit.
set /p method=...
if "%method%"=="1" goto one
if "%method%"=="2" goto two
if "%method%"=="3" goto exitsuccess

:one
echo.
echo Copying %fontname%FontPack.zip to your phones storage.
bin\adb shell mkdir /sdcard/FontPacks >nul
bin\adb push Output\%fontname%FontPack.zip /sdcard/FontPacks/>nul
echo Rebooting phone into recovery.
bin\adb reboot recovery >nul
goto exitsuccess
 
:two
echo.
echo Pushing files to system.
adb remount>nul
bin\adb push fonts\Roboto-Regular.ttf /system/fonts/>nul
bin\adb push fonts\Roboto-Italic.ttf /system/fonts/>nul
bin\adb push fonts\Roboto-Bold.ttf /system/fonts/>nul
bin\adb push fonts\Roboto-BoldItalic.ttf /system/fonts/>nul
bin\adb push fonts\Roboto-Thin.ttf /system/fonts/>nul
bin\adb push fonts\Roboto-ThinItalic.ttf /system/fonts/>nul
bin\adb push fonts\Roboto-Light.ttf /system/fonts/>nul
bin\adb push fonts\Roboto-LightItalic.ttf /system/fonts/>nul
bin\adb push fonts\RobotoCondensed-Regular.ttf /system/fonts/>nul
bin\adb push fonts\RobotoCondensed-Italic.ttf /system/fonts/>nul
bin\adb push fonts\RobotoCondensed-Bold.ttf /system/fonts/>nul
bin\adb push fonts\RobotoCondensed-BoldItalic.ttf /system/fonts/>nul
echo Rebooting phone.
bin\adb reboot >nul
goto exitsuccess

:exitsuccess
::Delete remnants
rmdir /s /q fonts
rmdir /s /q META-INF
echo.
echo All tasks performed successfully.
echo Press any key to exit . . .
pause >nul

:exitfail
echo Not all necessary fonts were found. 
echo Make sure that the input folder contains the four base fonts and try again.
echo Press any key to exit . . .
pause >nul
