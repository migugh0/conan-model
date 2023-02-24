#Copyright (c) 2016-2023 Knuth Project developers.
#Distributed under the MIT software license, see the accompanying
#file LICENSE or http://www.opensource.org/licenses/mit-license.php.
#SPDX-License-Identifier: MIT

# find_package(Catch2 2.13.0 REQUIRED)

#user scripts and functions
include("script_unit-test-helper") #Add the library unit_test_helper as interface

#Build external libraries
if(NOT CONAN_SETUP)
	add_subdirectory(${CMAKE_SOURCE_DIR}/include/external/Catch2-3.3.1 ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/Catch2-3.3.1)
endif()

#Executable compiling user_tests
set(TARGET_NAME "$user_tests")
message(FATAL_ERROR "${PROJECT_NAME} error: test folder not tested. Please put the correct files to add_executable() and remove this message")
add_executable(${TARGET_NAME} "main.cpp" "model.cpp" "user_database.cpp")
#Library compiling app_args external libraries: (PRIVATE Catch2::Catch2)
### Add package-install Catch2 Catch2 2.13.0 ###
find_package(Catch2 2.13.0 REQUIRED)
target_link_libraries(${TARGET_NAME} ${Catch2_LIBS}) #if package have extra libs link its libs here too
target_link_libraries(${TARGET_NAME} PRIVATE Catch2::Catch2) #link libraryname module::package

if(COVERAGE)
  include("script_code-coverage") #loads function_setup_coverage and get file "CodeCoverage.cmake" that loads setup_target_for_coverage_lcov
  function_setup_coverage(user_tests)
  function_setup_coverage(response_builder)
  function_setup_coverage(submodule1)
  set(COVERAGE_EXCLUDES "/usr/**" "/home/*/.conan/**" "*test*" "*build*")
  setup_target_for_coverage_lcov(NAME coverage EXECUTABLE ${CMAKE_CURRENT_BINARY_DIR}/user_tests)
endif()

if(RUN_TIDY)
  # function_setup_clang_tidy(user_tests) # Very annoying warnings because of catch2
  function_setup_clang_format(user_tests)
  function_setup_cmake_format(tests ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt) #this file
endif()
