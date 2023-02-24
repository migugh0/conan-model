#Copyright (c) 2016-2023 Knuth Project developers.
#Distributed under the MIT software license, see the accompanying
#file LICENSE or http://www.opensource.org/licenses/mit-license.php.
#SPDX-License-Identifier: MIT

# find_package(spdlog 1.11.0 REQUIRED)

#(for files "logger.cpp" "logger.hpp")

#Library compiling logger
set(TARGET_NAME "logger")
add_library(${TARGET_NAME} "logger.cpp")
#Library compiling logger extra include paths:
target_include_directories(${TARGET_NAME} PUBLIC ${CMAKE_SOURCE_DIR}/include)
#Library compiling logger extra defines:
if(${LOGGING} MATCHES ${CONSOLE})
	target_compile_definitions(${TARGET_NAME} PRIVATE -D CONSOLE_LOGGING)
endif()
if(${LOGGING} MATCHES ${SYSLOG})
	target_compile_definitions(${TARGET_NAME} PRIVATE -D SYSLOG_LOGGING)
endif()
#Library compiling app_args external libraries: (PUBLIC spdlog::spdlog)
### Add package-install spdlog spdlog 1.11.0 ###
find_package(spdlog 1.11.0 REQUIRED)
target_link_libraries(${TARGET_NAME} ${spdlog_LIBS}) #if package have extra libs link its libs here too
target_link_libraries(${TARGET_NAME} PUBLIC spdlog::spdlog) #link libraryname module::package
#Apply to some files the format indicated in the files .clang-tidy .clang-format .cmake-format
if(RUN_TIDY)
  function_setup_clang_tidy(logger)
  function_setup_clang_format(logger)
  function_setup_cmake_format(logger ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt) #this file
endif()
