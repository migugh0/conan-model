#Copyright (c) 2016-2023 Knuth Project developers.
#Distributed under the MIT software license, see the accompanying
#file LICENSE or http://www.opensource.org/licenses/mit-license.php.
#SPDX-License-Identifier: MIT

#Build external libraries
if(NOT CONAN_SETUP)
	add_subdirectory(${CMAKE_SOURCE_DIR}/include/external/fmt-9.1.0 ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/fmt-9.1.0) # Needs to be first
	add_subdirectory(${CMAKE_SOURCE_DIR}/include/external/Lyra-1.6 ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/Lyra-1.6)
	add_subdirectory(${CMAKE_SOURCE_DIR}/include/external/expected-lite-0.6.2 ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/expected-lite-0.6.2)
	add_subdirectory(${CMAKE_SOURCE_DIR}/include/external/spdlog-1.11.0 ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/spdlog-1.11.0)
endif()

#Build local libraries
add_subdirectory("logging") # Needs to be first
add_subdirectory("utility")

#Executable compiling ${PROJECT_NAME}
set(TARGET_NAME "${PROJECT_NAME}")
add_executable(${TARGET_NAME} "main.cpp")
#Executable compiling ${PROJECT_NAME} extra include paths:
target_include_directories(${TARGET_NAME} PUBLIC ${CMAKE_SOURCE_DIR}/include)
#Executable compiling ${PROJECT_NAME} extra defines:
if(CMAKE_BUILD_TYPE MATCHES "debug")
	target_compile_definitions(${TARGET_NAME} PUBLIC -D _DEBUG=1)
else()
	target_compile_definitions(${TARGET_NAME} PUBLIC -D NDEBUG=1)
endif()
target_compile_definitions(${TARGET_NAME} PUBLIC -D PROJECT_VERSION="${PROJECT_VERSION}")
#Executable compiling ${PROJECT_NAME} local libraries:
target_link_libraries(${TARGET_NAME} PRIVATE app_args server_logger)

#Apply to some files the format indicated in the files .clang-tidy .clang-format .cmake-format
if(RUN_TIDY)
	function_setup_clang_tidy(${PROJECT_NAME})
	function_setup_clang_format(${PROJECT_NAME})
	function_setup_cmake_format(main "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt") #this file
endif()