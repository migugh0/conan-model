#!/bin/bash
#Copyright (c) 2016-2023 Knuth Project developers.
#Distributed under the MIT software license, see the accompanying
#file LICENSE or http://www.opensource.org/licenses/mit-license.php.
#SPDX-License-Identifier: MIT

#Please to download it manually download all url links and unzip in ./include/external and ./include/wrappers creating this folders if necesary

#Change to the script directory for using it as working directory
cd "${0%/*}"

#Go to parent directory if we execute the script inside of install dir
[ ! -d "./install" ] && cd ..

echo ====================================================================
echo Knuth Project: We download and unzip the necessary external projects
echo ====================================================================
#external projects
read -p "Do you want to add to the project the external packages prerequisites instead using Conan? (Y/n) " yn 
case $yn in
	n )
	;;
	* )
		cd include
		mkdir -p external
		cd external
		
		if [ ! -d "fmt-9.1.0" ]
		then
			echo Downloading and unzip at ./include/external package fmt 9.1.0
			wget -nc -q --show-progress --progress=bar:force:noscroll https://github.com/fmtlib/fmt/archive/refs/tags/9.1.0.tar.gz
			tar -xf 9.1.0.tar.gz
			mv -T 9.1.0.tar.gz fmt-9.1.0.tar.gz
		fi
		
		if [ ! -d "spdlog-1.11.0" ]
		then
			echo Downloading and unzip at ./include/external package spdlog 1.11.0
			wget -nc -q --show-progress --progress=bar:force:noscroll https://github.com/gabime/spdlog/archive/refs/tags/v1.11.0.tar.gz
			tar -xf v1.11.0.tar.gz
			mv -T v1.11.0.tar.gz spdlog-1.11.0.tar.gz
		fi
		
		if [ ! -d "Lyra-1.6.1" ]
		then
			echo Downloading and unzip at ./include/external package Lyra 1.6.1
			wget -nc -q --show-progress --progress=bar:force:noscroll https://github.com/bfgroup/Lyra/archive/refs/tags/1.6.1.tar.gz
			tar -xf 1.6.1.tar.gz
			mv -T 1.6.1.tar.gz Lyra-1.6.1.tar.gz
		fi
		
		if [ ! -d "expected-lite-0.6.2" ]
		then
			echo Downloading and unzip at ./include/external package expected-lite 0.6.2
			wget -nc -q --show-progress --progress=bar:force:noscroll https://github.com/martinmoene/expected-lite/archive/refs/tags/v0.6.2.tar.gz
			tar -xf v0.6.2.tar.gz
			mv -T v0.6.2.tar.gz expected-lite-0.6.2.tar.gz
		fi
		
		if [ ! -d "Catch2-3.3.1" ]
		then
			echo Downloading and unzip at ./include/external package Catch2 3.3.1
			wget -nc -q --show-progress --progress=bar:force:noscroll https://github.com/catchorg/Catch2/archive/refs/tags/v3.3.1.tar.gz
			tar -xf v3.3.1.tar.gz
			mv -T v3.3.1.tar.gz Catch2-3.3.1.tar.gz
		fi
		
		#TODO: nanobench
		
		#TODO: jfalcou-eve
		
		cd ..
		cd ..
		echo Downloading finished
		echo
		;;
esac

#wrappers files (for using with UCRT64)
read -p "Do you want to add to the project the wrappers files needed for using MSYS/MSYS2 UCRT64 without the include files of MS Visual Studio? (Y/n) " yn 
case $yn in
	n )
	;;
	* )
		cd include
		mkdir -p wrappers
		cd wrappers
		
		echo Downloading files at ./include/wrappers
		
		wget -nc -q --show-progress --progress=bar:force:noscroll https://github.com/php/php-src/blob/master/win32/syslog.h
		
		cd ..
		cd ..
		echo Downloading finished
		echo
	;;
esac

#pause
read -rsp $'\nScript finished. Press any key to end the script...\n'