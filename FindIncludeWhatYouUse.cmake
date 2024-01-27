#[=======================================================================[.rst:
FindIncludeWhatYouUse.cmake
---------------------------

This module is intended for use with ``find_package`` and should not be imported on
its own.

It provides include-what-you-use (https://github.com/include-what-you-use/include-what-you-use/tree/clang_12),
an add-on tool that ensures that all headers necessary to make a specific c++ file
work are included and no headers that are not necessary are included.

It will download (if necessary) the include-what-you-use source (there is no binary
distribution provided) and compile it into the build directory. It will then create
an appropriate invocation string in ``CMAKE_CXX_INCLUDE_WHAT_YOU_USE`` and
``CMAKE_C_INCLUDE_WHAT_YOU_USE`` so that the tool will be run alongside compilation.

The only necessary integration point should be calling
``find_package(IncludeWhatYouUse)``.

Provides the variables
- ``IncludeWhatYouUse_FOUND``: bool, true if found
- ``IncludeWhatYouUse_EXECUTABLE``: the path to the iwyu binary
- ``CMAKE_CXX_INCLUDE_WHAT_YOU_USE``: internal variable with invocation command
- ``CMAKE_C_INCLUDE_WHAT_YOU_USE``: internal variable with invocation command

#]=======================================================================]

find_package(Clang REQUIRED)
find_package(Patch REQUIRED)

set(LOCALINSTALL_IWYU_DIR "${CMAKE_SOURCE_DIR}/stm32-tools/iwyu")
set(DL_IWYU_VERSION "0.16")

message(STATUS "installing include-what-you-use ${DL_IWYU_VERSION} to ${LOCALINSTALL_IWYU_DIR}")

FetchContent_Declare(IWYU_LOCALINSTALL
  PREFIX "${LOCALINSTALL_IWYU_DIR}/${CMAKE_HOST_SYSTEM_NAME}"
  # Patch does this: https://lists.llvm.org/pipermail/llvm-dev/2021-June/151554.html
  PATCH_COMMAND ${Patch_EXECUTABLE} -i ${CMAKE_CURRENT_LIST_DIR}/0001-Apply-fix-for-bad-path-in-clang-12.patch
  URL "https://include-what-you-use.org/downloads/include-what-you-use-${DL_IWYU_VERSION}.src.tar.gz")

FetchContent_GetProperties(IWYU_LOCALINSTALL)

if(NOT IWYU_LOCALINSTALL_POPULATED)
  message(STATUS "Downloading iwyu")
  FetchContent_Populate(IWYU_LOCALINSTALL)
  FetchContent_GetProperties(IWYU_LOCALINSTALL)
  message(STATUS "Downloaded iwyu")
  message(STATUS "configuring iwyu for build ${iwyu_localinstall_BINARY_DIR} from ${iwyu_localinstall_SOURCE_DIR}")

  execute_process(
    COMMAND ${CMAKE_COMMAND} -DCMAKE_C_COMPILER=${Clang_EXECUTABLE} -DCMAKE_CXX_COMPILER=${ClangXX_EXECUTABLE} -DCMAKE_PREFIX_PATH=${Clang_DIRECTORY} -DCMAKE_VERBOSE_MAKEFILE=1 ${iwyu_localinstall_SOURCE_DIR}
    COMMAND_ECHO STDOUT
    WORKING_DIRECTORY ${iwyu_localinstall_BINARY_DIR}
    COMMAND_ERROR_IS_FATAL ANY)
  message(STATUS "building iwyu")
  execute_process(
    COMMAND make
    COMMAND_ECHO STDOUT
    WORKING_DIRECTORY ${iwyu_localinstall_BINARY_DIR}
    COMMAND_ERROR_IS_FATAL ANY)
  message(STATUS "built to ${iwyu_localinstall_BINARY_DIR}")
endif()
find_program(IncludeWhatYouUse_EXECUTABLE
  include-what-you-use
  PATHS ${iwyu_localinstall_BINARY_DIR}/bin
  NO_DEFAULT_PATH
  REQUIRED)
set(IncludeWhatYouUse_FOUND TRUE)
set(IncludeWhatYouUse_DIRECTORY ${iwyu_localinstall_BINARY_DIR})
if(CMAKE_CXX_COMPILER_ID STREQUAL "Gnu")
  # If the compiler is gcc, then we need to make sure that iwyu (which uses
  # clang to function) is using the appropriate standard library and system
  # headers
  find_library(
    LIBSTDCPP
    NAMES "libstdc++" "stdc++"
    REQUIRED
    HINTS /usr/local/lib)
  find_path(
    LIBSTDCPP_INC
    NAMES array
    HINTS /usr/local/include
    REQUIRED
    )
  find_path(
    LIBSTDCPP_BITS
    NAMES "c++config.h"
    HINTS /usr/local/include
    REQUIRED
    )

  cmake_path(GET ${LIBSTDCPP_BITS} PARENT_PATH syspath)
  set(CMAKE_CXX_INCLUDE_WHAT_YOU_USE
    "${IncludeWhatYouUse_EXECUTABLE}"
    -stdlib=libstdc++
    -stdlib++-isystem=${LIBSTDCPP_INC}
    -cxx-isystem${syspath}
    )
else()
  set(CMAKE_CXX_INCLUDE_WHAT_YOU_USE "${IncludeWhatYouUse_EXECUTABLE}")
endif()
set(CMAKE_C_INCLUDE_WHAT_YOU_USE "${IncludeWhatYouUse_EXECUTABLE}")
