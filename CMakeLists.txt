#Copyright (c) 2016-2023 Knuth Project developers.
#Distributed under the MIT software license, see the accompanying
#file LICENSE or http://www.opensource.org/licenses/mit-license.php.
#SPDX-License-Identifier: MIT
cmake_minimum_required(VERSION 3.25)

project(model-exe
		VERSION 0.1.1
		LANGUAGES CXX C
)

#List of project external dependecies
# https://github.com/fmtlib/fmt/releases/download/9.1.0/fmt-9.1.0.zip
# https://github.com/gabime/spdlog/archive/refs/tags/v1.11.0.zip
# https://github.com/bfgroup/Lyra/archive/refs/tags/1.6.1.zip
# https://github.com/martinmoene/expected-lite/archive/refs/tags/v0.6.2.zip
# https://github.com/catchorg/Catch2/archive/refs/tags/v3.3.1.zip

#Set project defines
message("${PROJECT_NAME} message: Starting compiling '${PROJECT_NAME}' version ${PROJECT_VERSION}")
set(KTH_PROJECT_VERSION "v${PROJECT_VERSION}-dev")
message("${PROJECT_NAME} message: Compiling with KTH_PROJECT_VERSION=${KTH_PROJECT_VERSION}")
add_definitions("-D KTH_PROJECT_VERSION=${KTH_PROJECT_VERSION}")

#Set project binary dir correctly in case do not call cmake with -B build/out
message("${PROJECT_NAME} message: CMAKE_SOURCE_DIR=		${CMAKE_SOURCE_DIR}")
message("${PROJECT_NAME} message: CMAKE_BINARY_DIR=		${CMAKE_BINARY_DIR}")
set(PROJECT_BINARY_DIR "${PROJECT_SOURCE_DIR}/build/out") #build directory
set(EXECUTABLE_OUTPUT_PATH "${PROJECT_BINARY_DIR}/../bin") #executable files
set(CMAKE_PDB_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/pdb") #debug files .pdb
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/../lib") #.a
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/../lib") #.lib
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/../bin") #.dll

#user scripts and functions
#set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake) #list of paths for cmake packages, scripts and functions
include("script_options") #loads function_options
include("script_clang-tidy") #loads function_clang-tidy
include("script_clang-format") #loads function_clang-format
include("script_cmake-format") #loads function_cmake-format

#Set project options
option(CONAN_SETUP "use conan to setup all the dependencies" ON)
option(BUILD_MAIN "build the main funciton for this application" ON)
option(BUILD_TESTS "build the tests for this application" OFF)
option(RUN_TIDY "run clang-tidy" OFF)
option(COVERAGE "Enable code coverage testing" OFF)
#LOGGING=CONSOLE or LOGGING=SYSLOG
set(CONSOLE "console")
set(SYSLOG "syslog")
set(LOGGING_OPTIONS ${CONSOLE} ${SYSLOG})
function_options(LOGGING ${SYSLOG} "the desired logging mechanism to use" "${LOGGING_OPTIONS}") #LOGGING=SYSLOG

#This policy provides compatibility with projects that already use target_link_libraries() with the INTERFACE keyword
#on a target in another directory to add INTERFACE_LINK_LIBRARIES entries to be looked up in the target's directory
if(COVERAGE)
	cmake_policy(SET CMP0079 NEW)
endif()

#Check systems defines
message("${PROJECT_NAME} message: CMAKE_COMMAND= 		${CMAKE_COMMAND}")
message("${PROJECT_NAME} message: CMAKE_SYSTEM_NAME= 	${CMAKE_SYSTEM_NAME}")
string(REGEX MATCH "msys64" _MSYS_COMMAND_PARSED "${CMAKE_COMMAND}")
if(${_MSYS_COMMAND_PARSED} MATCHES "msys64")
	set(_IS_MSYS64 1)
	execute_process(COMMAND ${CMAKE_CXX_COMPILER} -dumpmachine RESULT_VARIABLE _GXXARCHITECTURE_RESULT OUTPUT_VARIABLE _GXXARCHITECTURE)
	if(${_GXXARCHITECTURE} MATCHES "x86_64-pc-msys")
		set(_IS_MSYS_POSIX 1)
	elseif(${_GXXARCHITECTURE} MATCHES "i686-w64-mingw32")
		set(_IS_MSYS_MINGW32 1)
	elseif(${_GXXARCHITECTURE} MATCHES "x86_64-w64-mingw32")
		set(_IS_MSYS_MINGW64 1)
	endif()
endif()
string(REGEX MATCH "ucrt64" _UCRT64_COMMAND_PARSED "${CMAKE_COMMAND}")
if(${_UCRT64_COMMAND_PARSED} MATCHES "ucrt64")
	set(_IS_UCRT64 1)
endif()
if(${CMAKE_SYSTEM_NAME} MATCHES "Windows")
	set(_IS_WIN 1)
elseif(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
	set(_IS_MAC 1)
elseif(${CMAKE_SYSTEM_NAME} MATCHES "Linux")
	file(READ "/proc/version" _SYS_VERSION)
	string(REGEX MATCH "Microsoft" _SYSTEM_VERSION_PARSED "${_SYS_VERSION}")
	if(${_SYSTEM_VERSION_PARSED} MATCHES "Microsoft")
		set(_IS_WSL 1)
	else()
		set(_IS_LINUX 1)
	endif()
endif()

#We use C++20 standar
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
if(NOT MSVC)
	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fcoroutines -std=c++20") # -std=gnu++20
endif()
set(CMAKE_BUILD_TYPE debug)
set(CMAKE_VERBOSE_MAKEFILE ON) #get more verbose output from Makefile builds and show each command line

#Changes for using diferent compilers and systems
if(MSYS OR _IS_MSYS64)
	if(CONAN_SETUP)
		message(WARNING "${PROJECT_NAME} warning: We are using MSYS/MSYS2 so we deactivate Conan setup")
		set(CONAN_SETUP OFF)
	endif()
	#static, lots of warnings, all warnings as errors
	#pthread define additional macros required for using the POSIX threads library. Use it for both compilation and linking.
	add_compile_options(-pthread -static -static-libgcc -static-libstdc++ -Wextra -Wall -Werror) # -pedantic
	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wfatal-errors -Wno-unknown-pragmas -Wno-unused-variable -Wno-unused-parameter" CACHE INTERNAL "" FORCE)
	set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -g" CACHE INTERNAL "" FORCE)
	set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -O3" CACHE INTERNAL "" FORCE)
	set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -pthread -static" CACHE INTERNAL "" FORCE)
endif()
if(_IS_UCRT64)
	#UCRT needs extra headers, that can get from MSVS or not, universal just means that it does not depend on a version of MSVS
	#C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\SDK\ScopeCppSDK\SDK\include\ucrt
	#C:\Program Files (x86)\Windows Kits\10\Redist\ucrt
	#https://stackoverflow.com/questions/9496129/cannot-find-syslog-h-on-windows
	#The include directories are added to the INCLUDE_DIRECTORIES directory property
	include_directories("${CMAKE_SOURCE_DIR}/include/wrappers")
	add_definitions("-D _UCRT")
	set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -l ucrt") #Needs -D _UCRT definition
endif()
if(_IS_MAC)
	add_definitions("-D MAC_OSX")
	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.7.sdk -mmacosx-version-min=10.7")
endif()

#Use ccache if installed to speed up build times
find_program(CCACHE_PROGRAM ccache)
if(CCACHE_PROGRAM)
	message("${PROJECT_NAME} message: Program ccache found = ${CCACHE_PROGRAM}")
	set_property(GLOBAL PROPERTY RULE_LAUNCH_COMPILE "${CCACHE_PROGRAM}")
	#Set up wrapper scripts
	set(C_LAUNCHER   "${CCACHE_PROGRAM}")
	set(CXX_LAUNCHER "${CCACHE_PROGRAM}")
else()
	message("${PROJECT_NAME} message: Program ccache not found")
endif()

#Interface libraries
#This libraries does not compile sources and does not produce a library artifact on disk.
#However, it may set properties and can be used as an argument to target_link_libraries() like any other target.
message("${PROJECT_NAME} message: CMAKE_PREFIX_PATH=	${CMAKE_PREFIX_PATH}")
message("${PROJECT_NAME} message: CMAKE_INCLUDE_PATH=	${CMAKE_INCLUDE_PATH}")
message("${PROJECT_NAME} message: CMAKE_LIBRARY_PATH=	${CMAKE_LIBRARY_PATH}")
add_library(model INTERFACE "include/model/model.hpp")
add_library(model::model ALIAS model)

#Apply to some files the format indicated in the files .clang-tidy .clang-format .cmake-format
if(RUN_TIDY)
	function_setup_clang_tidy(model) #file model.hpp
	function_setup_clang_format(model) #file model.hpp
	function_setup_cmake_format(main "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt") #this file
endif()

#We build the src
if(BUILD_MAIN)
	add_subdirectory(src)
endif()

#We build the test
if(BUILD_TESTS)
	add_subdirectory(test)
endif()