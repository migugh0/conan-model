::Copyright (c) 2016-2023 Knuth Project developers.
::Distributed under the MIT software license, see the accompanying
::file LICENSE or http://www.opensource.org/licenses/mit-license.php.
::SPDX-License-Identifier: MIT

::Please to configure it manually go to the instuctions at the end of the file

::Change to the script directory for using it as working directory
@echo off
chcp 65001>nul
cd /d %~dp0

::Go to parent directory if we execute the script inside of install dir
IF NOT EXIST install cd ..

echo ===============================================================
echo Knuth Project: Autoconfiguration install for Windows with Conan
echo ===============================================================
::Información inicial
echo Please install Conan and CMake before continue.
echo.
::
echo Required: CMake^>^=3.25
where cmake 1>nul 2>&1
IF NOT %ERRORLEVEL% == 0 (
	echo Installation failed: CMake command not found/not installed
	exit
)
echo Actual CMake:
cmake --version | findstr /r [0-2]
::
echo Required: Conan^>^=1.51
where conan 1>nul 2>&1
IF NOT %ERRORLEVEL% == 0 (
	echo Installation failed: Conan command not found/not installed
	exit
)
echo Actual Conan:
conan --version | findstr /r [0-2]
::
echo To begin configuring conan in the current directory press a key...
pause>nul
::
IF NOT DEFINED CONAN_USER_HOME (
	echo CONAN_USER_HOME not defined:
	setx CONAN_USER_HOME %USERPROFILE%
	echo .conan parent folder set in %USERPROFILE%
	echo Please restart the console to reload the CONAN_USER_HOME variable
	pause>nul
	exit
)
::
echo ==Set the user default profiles in the user installation:==
echo ===========================================================
IF NOT EXIST %CONAN_USER_HOME%/.conan (
	conan config install -t dir %CONAN_USER_HOME%/.conan
) ELSE (
    echo .conan already exists in %CONAN_USER_HOME%, so to proceed with the reinstall of the default profiles.
	conan config install --force -t dir %CONAN_USER_HOME%/.conan
)
::
echo ==Configure of local repository profiles:==
echo ===========================================
IF NOT EXIST .conan (
	echo Repository local profiles and repository local configuration will be loaded and used before
	echo searching for your global user profiles and global user configuration.
	echo Only if it does not exist the local configuration then it will use the user configuration.
	echo.
	conan config install -t dir .conan
) ELSE (
    echo .conan folder already exists in the repository, there is no need to install the local profiles.
)
::
echo ==We create the configuration files if they do not exist:==
echo ===========================================================
IF NOT EXIST conanfile.py (
	echo set conanfile.py to use the ninja profile
	conan lock create conanfile.py --version=0.0.0 -pr:b=ninja -pr:h=ninja --lockfile=conan.lock --lockfile-out=build/conan.lock
) ELSE (
    echo conanfile.py already exists, please remove conanfile.py if you want to recreate it.
)
mkdir build 1>nul 2>&1
echo deleting build/conan.lock to recreate it
del build\conan.lock 1>nul 2>&1
IF EXIST build\conan.lock echo The script cannot remove "build/conan.lock" file, please use root to remove it.
echo.
::
conan install conanfile.py --lockfile=build/conan.lock -if build --build missing
::
echo ======================
echo Installation finished. Press any key to end the script...
pause>nul
exit


::Manual order of commands
::To auto-detect your global user configuration use this commands (is easier and quicker)
conan install
conan profile new default --detect
::To create a personalized configuration edit a profile manually or use this commands
conan config init --force
conan profile update settings.compiler.libcxx=libstdc++11 default
conan profile update settings.os=Windows default
conan profile update settings.os_build=Windows default
conan profile update settings.arch=x86_64 default
conan profile update settings.arch_build=x86_64 default
conan profile update settings.build_type=Release default
conan profile update "settings.compiler=Visual Studio" default
conan profile update settings.compiler.version=17 default
conan profile update conf.tools.cmake.cmaketoolchain:generator=Ninja default
::First time in the directory where the repository is downloaded
conan config install -t dir .conan
::Each time we change the code in the directory where the repository is downloaded
conan lock create conanfile.py --version=0.0.0 -pr:b=default -pr:h=default --lockfile=conan.lock --lockfile-out=build/conan.lock
del build\conan.lock
conan install conanfile.py --lockfile=build/conan.lock -if build --build missing
cmake -S . -B build