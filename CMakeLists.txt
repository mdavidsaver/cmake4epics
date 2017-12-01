#=============================================================================
# Copyright 2015 Brookhaven Science Assoc. as operator of
#                Brookhaven National Lab
# Copyright 2015 Michael Davidsaver
#
# Distributed under the OSI-approved BSD License (the "License");
# see accompanying file LICENSE for details.
#
# This software is distributed WITHOUT ANY WARRANTY; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the License for more information.
#=============================================================================

project(osdetector C CXX)

message(STATUS "All CMake variables")

get_cmake_property(_variableNames VARIABLES)
foreach (_variableName ${_variableNames})
    message(STATUS "${_variableName}=${${_variableName}}")
endforeach()

if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE "Debug")
endif()

cmake_minimum_required(VERSION 2.8)

list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake/Modules")

message(STATUS "System classification provided by CMake")

# Host always available (computed)

message(STATUS "CMAKE_HOST_SYSTEM=${CMAKE_HOST_SYSTEM}")
message(STATUS "CMAKE_HOST_SYSTEM_NAME=${CMAKE_HOST_SYSTEM_NAME}")
message(STATUS "CMAKE_HOST_SYSTEM_PROCESSOR=${CMAKE_HOST_SYSTEM_PROCESSOR}")
message(STATUS "CMAKE_HOST_SYSTEM_VERSION=${CMAKE_HOST_SYSTEM_VERSION}")
message(STATUS "CMAKE_HOST_APPLE=${CMAKE_HOST_APPLE}")
message(STATUS "CMAKE_HOST_UNIX=${CMAKE_HOST_UNIX}")
message(STATUS "CMAKE_HOST_WIN32=${CMAKE_HOST_WIN32}")

# Target from toolchain

message(STATUS "CMAKE_SYSTEM=${CMAKE_SYSTEM}")
message(STATUS "CMAKE_SYSTEM_NAME=${CMAKE_SYSTEM_NAME}")
message(STATUS "CMAKE_SYSTEM_PROCESSOR=${CMAKE_SYSTEM_PROCESSOR}")
message(STATUS "CMAKE_SYSTEM_VERSION=${CMAKE_SYSTEM_VERSION}")

# Target computed

message(STATUS "APPLE=${APPLE}")
message(STATUS "UNIX=${UNIX}")
message(STATUS "WIN32=${WIN32}")

# Target only computed

message(STATUS "MINGW=${MINGW}")
message(STATUS "CYGWIN=${CYGWIN}")
message(STATUS "MSVC=${MSVC}")
message(STATUS "BORLAND=${BORLAND}")

# Target compiler computed

message(STATUS "CMAKE_COMPILER_IS_GNUCC=${CMAKE_COMPILER_IS_GNUCC}")
message(STATUS "CMAKE_COMPILER_IS_GNUCXX=${CMAKE_COMPILER_IS_GNUCXX}")
message(STATUS "CMAKE_GNUtoMS=${CMAKE_GNUtoMS}")

message(STATUS "CMAKE_C_PLATFORM_ID=${CMAKE_C_PLATFORM_ID}")
message(STATUS "CMAKE_CXX_PLATFORM_ID=${CMAKE_CXX_PLATFORM_ID}")
message(STATUS "CMAKE_C_COMPILER_ID=${CMAKE_C_COMPILER_ID}")
message(STATUS "CMAKE_CXX_COMPILER_ID=${CMAKE_CXX_COMPILER_ID}")
message(STATUS "CMAKE_C_COMPILER_VERSION=${CMAKE_C_COMPILER_VERSION}")
message(STATUS "CMAKE_CXX_COMPILER_VERSION=${CMAKE_CXX_COMPILER_VERSION}")

message(STATUS "CMAKE_SIZEOF_VOID_P=${CMAKE_SIZEOF_VOID_P}")

# Our specials

message(STATUS "RTEMS=${RTEMS}")
message(STATUS "RTEMS_BSP=${RTEMS_BSP}")

#message(STATUS "=${}")

include(TestBigEndian)
test_big_endian(target_endian)
message(STATUS "Target big endian=${target_endian}")

message(STATUS "Best guess at EPICS OS class and target")

find_package(EPICSHostArch)

message(STATUS "EPICS_HOST_CLASS=${EPICS_HOST_CLASS}")
message(STATUS "EPICS_HOST_CLASSES=${EPICS_HOST_CLASSES}")
message(STATUS "EPICS_HOST_COMPILER=${EPICS_HOST_COMPILER}")
message(STATUS "EPICS_HOST_ARCHS=${EPICS_HOST_ARCHS}")

find_package(EPICSTargetArch)

message(STATUS "EPICS_TARGET_CLASS=${EPICS_TARGET_CLASS}")
message(STATUS "EPICS_TARGET_CLASSES=${EPICS_TARGET_CLASSES}")
message(STATUS "EPICS_TARGET_COMPILER=${EPICS_TARGET_COMPILER}")
message(STATUS "EPICS_TARGET_ARCHS=${EPICS_TARGET_ARCHS}")

message(STATUS "Find EPICS Base")

find_package(EPICS COMPONENTS ca IOC)

message(STATUS "EPICS_FOUND=${EPICS_FOUND}")
message(STATUS "EPICS_BASE_DIR=${EPICS_BASE_DIR}")
message(STATUS "EPICS_INCLUDE_DIRS=${EPICS_INCLUDE_DIRS}")
message(STATUS "EPICS_TARGET_ARCH=${EPICS_TARGET_ARCH}")
message(STATUS "EPICS_LIBRARIES=${EPICS_LIBRARIES}")
message(STATUS "EPICS_Com_LIBRARY=${EPICS_Com_LIBRARY}")
message(STATUS "EPICS_ca_LIBRARY=${EPICS_ca_LIBRARY}")
message(STATUS "EPICS_IOC_LIBRARIES=${EPICS_IOC_LIBRARIES}")
message(STATUS "EPICSBase_VERSION=${EPICSBase_VERSION}")
message(STATUS "EPICSBase_VERSION_STRING=${EPICSBase_VERSION_STRING}")
message(STATUS "EPICS_DEFINITIONS=${EPICS_DEFINITIONS}")

find_package(EPICSTools)

message(STATUS "EPICSTOOLS_FOUND=${EPICSTools_FOUND}")

add_subdirectory(basic)
if(EPICS_FOUND)
  add_subdirectory(caApp)
  if(EPICSTOOLS_FOUND)
    add_subdirectory(iocApp)
  else()
    message(WARNING "EPICSTools Not found, skipping IOC example")
  endif()
else()
  message(WARNING "EPICS Not found, skipping examples")
endif()
