#Copyright (c) 2016-2023 Knuth Project developers.
#Distributed under the MIT software license, see the accompanying
#file LICENSE or http://www.opensource.org/licenses/mit-license.php.
#SPDX-License-Identifier: MIT

# find_package(lyra 1.6.1 REQUIRED)
# find_package(fmt 9.1.0 REQUIRED)
# find_package(expected-lite 0.6.2 REQUIRED)

#(for files "app_args.cpp" "app_args.hpp")

#Library compiling app_args
set(TARGET_NAME "app_args")
add_library(${TARGET_NAME} "app_args.cpp")
#Library compiling app_args extra include paths:
target_include_directories(${TARGET_NAME} PUBLIC ${CMAKE_SOURCE_DIR}/include)
#Library compiling app_args external libraries: (PUBLIC nonstd::expected-lite PRIVATE bfg::lyra fmt::fmt)
### Add package-install fmt fmt 9.1.0 ###
find_package(fmt 9.1.0 REQUIRED)
target_link_libraries(${TARGET_NAME} ${fmt_LIBS}) #if package have extra libs link its libs here too
target_link_libraries(${TARGET_NAME} PRIVATE fmt::fmt) #link libraryname module::package
### Add package or include bfg lyra 1.6.1 ###
if(CONAN_SETUP)
	find_package(lyra 1.6.1 REQUIRED)
endif()
if(NOT CONAN_SETUP)
	target_include_directories(${TARGET_NAME} PRIVATE include/external/Lyra-1.6.1/include)
endif()
target_link_libraries(${TARGET_NAME} PRIVATE bfg::lyra) #link libraryname module::package
### Add package or include nonstd expected-lite 0.6.2 ###
if(CONAN_SETUP)
	find_package(expected-lite 0.6.2 REQUIRED)
endif()
if(NOT CONAN_SETUP)
	target_include_directories(${TARGET_NAME} PUBLIC include/external/expected-lite-0.6.2)
endif()
target_link_libraries(${TARGET_NAME} PUBLIC nonstd::expected-lite) #link libraryname module::package

#(for file "server_logger.hpp")

#Library compiling server_logger
set(TARGET_NAME "server_logger")
add_library(${TARGET_NAME} INTERFACE)
#Library compiling server_logger extra include paths:
target_include_directories(${TARGET_NAME} INTERFACE ${CMAKE_SOURCE_DIR}/include)
#Library compiling server_logger local libraries:
target_link_libraries(${TARGET_NAME} INTERFACE logger)

#Apply to some files the format indicated in the files .clang-tidy .clang-format .cmake-format
if(RUN_TIDY)
  function_setup_clang_tidy(app_args)
  function_setup_clang_tidy(server_logger)
  function_setup_clang_format(app_args)
  function_setup_clang_format(server_logger)
  function_setup_cmake_format(src-utility ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt) #this file
endif()
