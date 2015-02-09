# Determine EPICS target name and OS class of Host
#
# In general compilation is only done for the Target
# and the Host used to find programs (eg. perl or flex)
#
# So, while best effort will be made to determine
# EPICS_HOST_CLASS and and EPICS_HOST_COMPILER, their
# use is discouraged.
#
# Use as:
#  find_package(EPICSHostArch)
#
# Creates variables:
#  EPICS_HOST_ARCHS      - List of possible target names (best match first)
#  EPICS_HOST_CLASS      - Primary (first) OSI system class
#  EPICS_HOST_CLASSES    - List of all OSI classes in order of decreasing preference ('default' is last)
#  EPICS_HOST_COMPILER - Compiler name (Base >=3.15 only)
#

cmake_minimum_required(VERSION 2.8)

include(FindPackageHandleStandardArgs)

# CMake 2.8 promises to provide the following variables
# with information about the Host.
# Every other variable must be assumed to describe the target
#
# CMAKE_HOST_SYSTEM_NAME
# CMAKE_HOST_SYSTEM_PROCESSOR
# CMAKE_HOST_SYSTEM_VERSION
# CMAKE_HOST_APPLE
# CMAKE_HOST_UNIX
# CMAKE_HOST_WIN32
#

if(CMAKE_HOST_UNIX)
  if(CMAKE_HOST_SYSTEM_NAME MATCHES Linux)
    set(EPICS_HOST_CLASS Linux)
    set(EPICS_HOST_CLASSES Linux posix default)
    set(EPICS_HOST_COMPILER gcc)

    if(CMAKE_HOST_SYSTEM_PROCESSOR MATCHES "^i(.86)$")
      #string(REGEXP REPLACE "^i(.86)$" "\\1" _cpunum ${CMAKE_HOST_SYSTEM_PROCESSOR})
      set(EPICS_HOST_ARCHS "linux-x86" "linux-${CMAKE_MATCH_1}")
      #unset(_cpunum)

    elseif(CMAKE_HOST_SYSTEM_PROCESSOR MATCHES "^x86_64$")
      set(EPICS_HOST_ARCHS "linux-x86_64")

    elseif(CMAKE_HOST_SYSTEM_PROCESSOR MATCHES "^(powerpc|ppc)$")
      set(EPICS_HOST_ARCHS "linux-ppc")

    elseif(CMAKE_HOST_SYSTEM_PROCESSOR MATCHES "^(powerpc|ppc)64$")
      set(EPICS_HOST_ARCHS "linux-ppc64")

    else()
      message(WARNING "Unknown Linux Variant: ${CMAKE_HOST_SYSTEM_PROCESSOR}")
    endif()

  elseif(CMAKE_HOST_SYSTEM_NAME MATCHES SunOS)
    set(EPICS_HOST_CLASS solaris)
    set(EPICS_HOST_CLASSES solaris posix default)
    set(EPICS_HOST_COMPILER gcc)

    if(CMAKE_HOST_SYSTEM_PROCESSOR MATCHES "^i.86$")
      set(EPICS_HOST_ARCHS "solaris-x86" "solaris-x86-gnu")

    elseif(CMAKE_HOST_SYSTEM_PROCESSOR MATCHES "^x86_64$")
      set(EPICS_HOST_ARCHS "solaris-x86_64" "solaris-x86_64-gnu")

    else()
      message(WARNING "Unknown SunOS Variant: ${CMAKE_HOST_SYSTEM_PROCESSOR}")
    endif()

  else()
    message(WARNING "Unknown *nix Variant: ${CMAKE_HOST_SYSTEM_NAME}")

  endif()

elseif(CMAKE_HOST_WIN32)
  set(EPICS_HOST_CLASS WIN32)
  set(EPICS_HOST_CLASSES WIN32 default)

  if(CMAKE_HOST_SYSTEM_PROCESSOR MATCHES "64$")
  
    if(CMAKE_HOST_SYSTEM_NAME MATCHES MinGW)
      set(EPICS_HOST_ARCHS "windows-x64-mingw")
      set(EPICS_HOST_COMPILER gcc)
  
    elseif(CMAKE_HOST_SYSTEM_NAME MATCHES Windows)
      set(EPICS_HOST_ARCHS "windows-x64")
      set(EPICS_HOST_COMPILER msvc)

    else()
      message(WARNING "Unknown Windows 64 variant: ${CMAKE_HOST_SYSTEM_NAME}")
      message(WARNING "Assuming default")
      set(EPICS_HOST_ARCHS "windows-x64" "windows-x64-static")
      set(EPICS_HOST_COMPILER msvc)
    endif(MINGW)
  
  elseif(CMAKE_HOST_SYSTEM_PROCESSOR MATCHES "86$")
  
    if(CMAKE_HOST_SYSTEM_NAME MATCHES MinGW)
      set(EPICS_HOST_ARCHS "win32-x86-mingw")
      set(EPICS_HOST_COMPILER gcc)
    
    elseif(CMAKE_HOST_SYSTEM_NAME MATCHES Cygwin)
      set(EPICS_HOST_ARCHS "win32-x86-cygwin")
      set(EPICS_HOST_COMPILER gcc)
  
    elseif(CMAKE_HOST_SYSTEM_NAME MATCHES Windows)
      set(EPICS_HOST_ARCHS "win32-x86")
      set(EPICS_HOST_COMPILER msvc)

    else()
      message(WARNING "Unknown Windows 32 variant: ${CMAKE_HOST_SYSTEM_NAME}")
      message(WARNING "Assuming default")
      set(EPICS_HOST_ARCHS "win32-x86")
      set(EPICS_HOST_COMPILER msvc)
    endif()

  else()
    message(WARNING "Unknown Windows variant: ${CMAKE_HOST_SYSTEM_PROCESSOR}")
  endif()

elseif(CMAKE_HOST_APPLE)
  set(EPICS_HOST_CLASS Darwin)
  set(EPICS_HOST_CLASSES Darwin default)
  set(EPICS_HOST_COMPILER clang)
  
  if(CMAKE_HOST_SYSTEM_PROCESSOR MATCHES "86")
    set(EPICS_HOST_ARCHS "darwin-x86")

  elseif(CMAKE_HOST_SYSTEM_PROCESSOR MATCHES "^(powerpc|ppc)$")
    set(EPICS_HOST_ARCHS "darwin-ppc")

  else()
    message(WARNING "Unknown Apple variant: ${CMAKE_HOST_SYSTEM_NAME}")
  endif()

else()
  message(WARNING "Unable to determine EPICS host OS class")
endif()

if(NOT EPICS_HOST_COMPILER)
  message(WARNING "Unable to guess host compiler")
endif()

if(CMAKE_BUILD_TYPE STREQUAL "DEBUG")
  # prepend the -debug version of all target names
  list(REVERSE EPICS_HOST_ARCHS)
  foreach(_arch IN LISTS EPICS_HOST_ARCHS)
    list(APPEND EPICS_HOST_ARCHS "${_arch}-debug")
  endforeach()
  unset(_arch)
  list(REVERSE EPICS_HOST_ARCHS)
endif()

find_package_handle_standard_args(EPICSHostArch
  REQUIRED_VARS
    EPICS_HOST_ARCHS
    EPICS_HOST_CLASS EPICS_HOST_CLASSES
)
