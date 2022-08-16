#[=======================================================================[.rst:
FindPoetry.cmake
---------------

This module is intended for use with ``find_package`` and should not be imported on
its own.

It will download and install the poetry package manager.
#]=======================================================================]
include(FetchContent)

message(STATUS "Checking for installed Python package")
set(Python_FIND_UNVERSIONED_NAMES "FIRST")  # Helps find pyenv if installed
find_package(Python COMPONENTS Interpreter Development)
if(NOT ${Python_FOUND})
	message(FATAL_ERROR "Could not find installed python version. Cannot install poetry. Exiting...")
else()
	message(STATUS "Found Python executable at: ${Python_EXECUTABLE}")
endif()


set(LOCALINSTALL_POETRY_DIR "${CMAKE_SOURCE_DIR}/stm32-tools/poetry")
message(STATUS "Downloading poetry install script to: ${LOCALINSTALL_POETRY_DIR}")

message(STATUS "Installing Poetry")
FetchContent_Declare(
	POETRY_LOCALINSTALL
	PREFIX ${LOCALINSTALL_POETRY_DIR}
	DOWNLOAD_DIR ${LOCALINSTALL_POETRY_DIR}
	URL "https://install.python-poetry.org/"
	DOWNLOAD_NAME "install_poetry.py"
	DOWNLOAD_NO_EXTRACT True
)
FetchContent_MakeAvailable(POETRY_LOCALINSTALL)
execute_process(COMMAND ${Python_EXECUTABLE} install_poetry.py
	WORKING_DIRECTORY ${LOCALINSTALL_POETRY_DIR}
)
