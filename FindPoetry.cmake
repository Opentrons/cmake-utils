#[=======================================================================[.rst:
FindClang.cmake
---------------

This module is intended for use with ``find_package`` and should not be imported on
its own.

It will download and install the poetry package manager.
#]=======================================================================]

if(NOT WIN32)
  string(ASCII 27 Esc)
  set(ColourReset "${Esc}[m")
  set(BoldRed     "${Esc}[1;31m")
  set(BoldCyan    "${Esc}[1;36m")
endif()

message(STATUS "${BoldCyan}Checking for installed Python package${ColourReset}")
set(Python_FIND_UNVERSIONED_NAMES "FIRST")  # Helps find pyenv if installed
find_package(Python COMPONENTS Interpreter Development)
if(NOT ${Python_FOUND})
	message(FATAL_ERROR "${BoldRed}Could not find installed python version. Cannot install poetry. Exiting...${ColourReset}")
else()
	message(STATUS "${BoldCyan}Found Python executable at: ${Python_EXECUTABLE}${ColourReset}")
endif()


set(LOCALINSTALL_POETRY_DIR "${CMAKE_SOURCE_DIR}/poetry")
message(STATUS "${BoldCyan}Downloading poetry install script to: ${LOCALINSTALL_POETRY_DIR}${ColourReset}")

message(STATUS "${BoldCyan}Installing Poetry${ColourReset}")
file(DOWNLOAD "https://install.python-poetry.org/" "${LOCALINSTALL_POETRY_DIR}/install_poetry.py")
execute_process(COMMAND ${Python_EXECUTABLE} install_poetry.py
	WORKING_DIRECTORY ${LOCALINSTALL_POETRY_DIR}
)
