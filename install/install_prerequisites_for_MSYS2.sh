#!/bin/bash
#Copyright (c) 2016-2023 Knuth Project developers.
#Distributed under the MIT software license, see the accompanying
#file LICENSE or http://www.opensource.org/licenses/mit-license.php.
#SPDX-License-Identifier: MIT

#Please to install it manually copy all the commands you want to install in the terminal manually

echo ======================================================================
echo Knuth Project: Autoconfiguration install for using the subsystem MSYS2
echo ======================================================================
#Update all
echo ===Updating first MSYS2 system and packages===
read -p "Do you want to update the entire system first (may require restarting the terminal)? (Y/n) " yn 
case $yn in
	n )
	;;
	* )
		echo Update system with pacman -Syuuc:
		echo -S sincronice packages
		echo -y refresh packages downloading fresh package info from the server
		echo -uu upgrade installed packages (-uu enables downgrades)
		echo -c clean the old packages from cache directory
		pacman -Syuuc
	;;
esac
echo ==================
#Install make, autoconf, ninja, etc
echo ===We install packages to configure, compile and link===
read -p "Do you want to install packages to configure, compile and link? (Y/n) " yn 
case $yn in
	n )
	;;
	* )
		pacman -S base-devel
		pacman -S development
		yes | pacman -S mingw-w64-x86_64-cmake
		yes | pacman -S mingw-w64-x86_64-make
		yes | pacman -S mingw-w64-x86_64-gcc
		yes | pacman -S mingw-w64-x86_64-gdb
		yes | pacman -S mingw-w64-x86_64-ninja
	;;
esac
echo ==================
#Install ccache, qt5, premake, etc
echo ===We install extra packages to configure, compile and link [optional]===
read -p "Do you want to install the extra packages " yn 
case $yn in
	n )
	;;
	* )
		pacman -S git
		pacman -S liblzma
		pacman -S openssl
		pacman -S mingw-w64-x86_64-toolchain
		pacman -S mingw-w64-x86_64-qt5
		pacman -S mingw-w64-x86_64-qt5-debug
		yes | pacman -S mingw-w64-x86_64-ccache
		yes | pacman -S mingw-w64-x86_64-protobuf
		yes | pacman -S mingw-w64-x86_64-premake
		yes | pacman -S mingw-w64-x86_64-doxygen
		yes | pacman -S mingw-w64-x86_64-python
		yes | pacman -S mingw-w64-x86_64-python-pip
		yes | pacman -S mingw-w64-x86_64-python-sphinx
		yes | pacman -S mingw-w64-x86_64-7zip
		yes | pacman -S mingw-w64-x86_64-gtest
		yes | pacman -S mingw-w64-x86_64-graphviz
	;;
esac
echo ==================
#pause
read -rsp $'\nInstallation finished. Press any key to end the script...\n'