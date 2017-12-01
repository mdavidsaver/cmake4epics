# Find EPICS Base for the current target
#
# Use as:
#  find_package(EPICS
#    COMPONENTS <library/component names except Com>
#  )
#
# Creates variables:
#  EPICS_FOUND
#  EPICS_BASE_DIR
#  EPICS_INCLUDE_DIRS - All include directories (common, OS, and compiler)
#  EPICS_LIB_DIR
#  EPICS_LIBRARIES
#  EPICS_DEFINITIONS
#
#  EPICS_<lib>_LIBRARY - For each component and Com
#
#  EPICS_CORE_INCLUDE_DIR
#  EPICS_OS_INCLUDE_DIR
#  EPICS_COMP_INCLUDE_DIR - >=3.15 only
#
# Components:
#  Component names may be library names (eg. "ca" for libca).
#  It is unnecessary to include Com as it is automatically
#  added.
#
#  In addition to library names, the component "IOC" may be used
#  as an alias for the libraries named by EPICS_BASE_IOC_LIBS.
#  And "HOST" is an alias for EPICS_BASE_HOST_LIBS.
#
#  EPICS_IOC_LIBRARIES
#  EPICS_HOST_LIBRARIES
#
# Version:
#  EPICSBase_VERSION

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

if(EPICS_FIND_REQUIRED)
  # If we can't figure out the target then everything after
  # will fail.  So stop here if we have to.
  find_package(EPICSTargetArch REQUIRED)
else()
  find_package(EPICSTargetArch)
endif()

find_path(EPICS_BASE_DIR include/epicsVersion.h
  HINTS ENV EPICS_BASE # look here first
  PATHS
    /usr/lib/epics
    /usr/local/epics/base
    /usr/local/epics
    /opt/epics/base
    /opt/epics
  DOC "Root directory for EPICS Base install"
  NO_DEFAULT_PATH
  NO_CMAKE_SYSTEM_PATH
  NO_CMAKE_FIND_ROOT_PATH
)

if(EPICS_BASE_DIR)
  message(STATUS "Using EPICS_BASE_DIR=${EPICS_BASE_DIR}")
  set(EPICS_CORE_INCLUDE_DIR "${EPICS_BASE_DIR}/include")
  set(EPICS_OS_INCLUDE_DIR   "${EPICS_BASE_DIR}/include/os/${EPICS_TARGET_CLASS}")
  set(EPICS_COMP_INCLUDE_DIR "${EPICS_BASE_DIR}/include/compiler/${EPICS_TARGET_COMPILER}")
  set(EPICS_INCLUDE_DIRS
    "${EPICS_CORE_INCLUDE_DIR}"
    "${EPICS_OS_INCLUDE_DIR}"
    "${EPICS_COMP_INCLUDE_DIR}"
  )

else(NOT EPICS_FIND_QUIETLY)
  message(WARNING "Couldn't find EPICS_BASE_DIR!")
endif()

# Search through the various possible target archs
if(NOT DEFINED EPICS_TARGET_ARCH)
  find_library(EPICS_X_LIBRARY Com
    PATHS
      ${EPICS_BASE_DIR}/lib
    PATH_SUFFIXES
      ${EPICS_TARGET_ARCHS}
    NO_DEFAULT_PATH
    NO_CMAKE_SYSTEM_PATH
    NO_CMAKE_FIND_ROOT_PATH
  )
  if(EPICS_X_LIBRARY)
    mark_as_advanced(EPICS_X_LIBRARY)
    get_filename_component(EPICS_X_PATH "${EPICS_X_LIBRARY}" PATH)
    get_filename_component(EPICS_TARGET_ARCH "${EPICS_X_PATH}" NAME CACHE)
  endif()
endif()

if(EPICS_BASE_DIR AND EPICS_TARGET_ARCH)
endif()

# Detect EPICS Base version from epicsVersion.h

include(${CMAKE_CURRENT_BINARY_DIR}/EPICSVersion.cmake OPTIONAL RESULT_VARIABLE alreadyhaveepicsver)
if(NOT alreadyhaveepicsver)
  if(EPICS_TARGET_COMPILER STREQUAL msvc)
    execute_process(COMMAND
                     ${CMAKE_CXX_COMPILER} -C -E -I${EPICS_CORE_INCLUDE_DIR} ${CMAKE_CURRENT_LIST_DIR}/../Templates/EPICSVersion.cmake.in
                    RESULT_VARIABLE result
                    OUTPUT_FILE ${CMAKE_CURRENT_BINARY_DIR}/EPICSVersion.cmake
    )

  elseif(EPICS_TARGET_COMPILER STREQUAL solStudio)
    execute_process(COMMAND
                     ${CMAKE_CXX_COMPILER} -E -Qn -I${EPICS_CORE_INCLUDE_DIR} ${CMAKE_CURRENT_LIST_DIR}/../Templates/EPICSVersion.cmake.in
                    RESULT_VARIABLE result
                    OUTPUT_FILE ${CMAKE_CURRENT_BINARY_DIR}/EPICSVersion.cmake
    )

  else()
    # Assume GCC-ish for anything else
    execute_process(COMMAND
                     ${CMAKE_CXX_COMPILER} -x c -E -I${EPICS_CORE_INCLUDE_DIR} ${CMAKE_CURRENT_LIST_DIR}/../Templates/EPICSVersion.cmake.in
                    RESULT_VARIABLE result
                    OUTPUT_FILE ${CMAKE_CURRENT_BINARY_DIR}/EPICSVersion.cmake
    )
  endif()
  # re-process generated .cmake to remove any leftovers
  #  MSVC apparently leaves some C block comments
  file(STRINGS ${CMAKE_CURRENT_BINARY_DIR}/EPICSVersion.cmake epics_version_cmake REGEX "^set")

  file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/EPICSVersion.cmake "\n")
  foreach(line IN LISTS epics_version_cmake)
    file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/EPICSVersion.cmake "${line}\n")
  endforeach()

  include(${CMAKE_CURRENT_BINARY_DIR}/EPICSVersion.cmake OPTIONAL)
endif()
unset(alreadyhaveepicsver)
set(EPICSBase_VERSION "${EPICSBase_MAJOR}.${EPICSBase_MINOR}.${EPICSBase_MODIFICATION}.${EPICSBase_PATCH_LEVEL}")

set(EPICS${EPICSBase_MAJOR}${EPICSBase_MINOR} TRUE)

# Find libraries

# Always find libCom
list(APPEND EPICS_FIND_COMPONENTS Com)

if(EPICSBase_VERSION VERSION_GREATER 3.15.0.0)
  set(EPICSBase_IOC_LIB_NAMES dbRecStd dbCore ca Com)
  set(EPICSBase_HOST_LIB_NAMES cas gdd ca Com)
else()
  set(EPICSBase_IOC_LIB_NAMES recIoc softDevIoc miscIoc rsrvIoc dbtoolsIoc asIoc dbIoc registryIoc dbStaticIoc ca Com)
  set(EPICSBase_HOST_LIB_NAMES cas gdd asHost dbStaticHost registryIoc ca Com)
endif()

# Handling for aliased components HOST and IOC
# Replace with the full library list

list(FIND EPICS_FIND_COMPONENTS IOC epioc)
if(epioc GREATER -1)
  list(REMOVE_AT EPICS_FIND_COMPONENTS ${epioc})
  list(APPEND EPICS_FIND_COMPONENTS ${EPICSBase_IOC_LIB_NAMES})
endif()

list(FIND EPICS_FIND_COMPONENTS HOST ephost)
if(ephost GREATER -1)
  list(REMOVE_AT EPICS_FIND_COMPONENTS ${ephost})
  list(APPEND EPICS_FIND_COMPONENTS ${EPICSBase_HOST_LIB_NAMES})
endif()

list(REMOVE_DUPLICATES EPICS_FIND_COMPONENTS)

foreach(comp IN LISTS EPICS_FIND_COMPONENTS)
  find_library(EPICS_${comp}_LIBRARY ${comp}
    PATHS
      ${EPICS_BASE_DIR}/lib/${EPICS_TARGET_ARCH}
    NO_DEFAULT_PATH
    NO_CMAKE_SYSTEM_PATH
    NO_CMAKE_FIND_ROOT_PATH
  )
  mark_as_advanced(EPICS_${comp}_LIBRARY)
  if(EPICS_${comp}_LIBRARY)
    set(EPICS_${comp}_FOUND TRUE)
    list(APPEND EPICS_LIBRARIES ${EPICS_${comp}_LIBRARY})
  endif()
endforeach()

# Handling for aliased components HOST and IOC
# Restore them so that error checking is done

if(epioc GREATER -1)
  list(APPEND EPICS_FIND_COMPONENTS IOC)
  set(EPICS_IOC_FOUND TRUE)
  foreach(comp IN LISTS EPICSBase_IOC_LIB_NAMES)
    if(EPICS_${comp}_LIBRARY)
      list(APPEND EPICS_IOC_LIBRARIES ${EPICS_${comp}_LIBRARY})
    else()
      set(EPICS_IOC_FOUND FALSE)
      if(NOT EPICS_FIND_QUIETLY)
        message(WARNING "Missing IOC component ${comp}")
      endif()
    endif()
  endforeach()
endif()

if(ephost GREATER -1)
  list(APPEND EPICS_FIND_COMPONENTS HOST)
  set(EPICS_HOST_FOUND TRUE)
  foreach(comp IN LISTS EPICSBase_HOST_LIB_NAMES)
    if(EPICS_${comp}_LIBRARY)
      list(APPEND EPICS_HOST_LIBRARIES ${EPICS_${comp}_LIBRARY})
    else()
      set(EPICS_HOST_FOUND FALSE)
      if(NOT EPICS_FIND_QUIETLY)
        message(WARNING "Missing HOST component ${comp}")
      endif()
    endif()
  endforeach()
endif()

unset(epioc)
unset(ephost)
unset(comp)

# EPICS' own target/compiler specific macros
# equivalent of ${OP_SYS_CPPFLAGS}
# prefer for new code --> https://sourceforge.net/p/predef/wiki/Home/ for alternatives

if(UNIX)
  list(APPEND EPICS_DEFINITIONS "UNIX")
endif()

if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
  list(APPEND EPICS_DEFINITIONS "linux") # use __linux__
endif()
if(MINGW)
  list(APPEND EPICS_DEFINITIONS "_MINGW") # use __MINGW32__ or __MINGW64__
endif()

if(NOT EPICS_DEFINITIONS)
  set(EPICS_DEFINITIONS "")
endif()

# Find any OS specific extra libraries
# equivalent to ${OP_SYS_LDLIBS}
if(WIN32)
  find_library(EPICS_ws2_32_LIBRARY ws2_32
    DOC "winsock 2 library"
  )
  if(EPICS_ws2_32_LIBRARY)
    list(APPEND EPICS_Com_LIBRARY ${EPICS_ws2_32_LIBRARY})
    list(APPEND EPICS_LIBRARIES ${EPICS_ws2_32_LIBRARY})
    list(APPEND EPICS_IOC_LIBRARIES ${EPICS_ws2_32_LIBRARY})
    list(APPEND EPICS_HOST_LIBRARIES ${EPICS_ws2_32_LIBRARY})
  else()
    if(NOT EPICS_FIND_QUIETLY)
      message(WARNING "Can't find winsock")
    endif()
  endif()

elseif(RTEMS)
  find_library(RTEMSCPU rtemscpu)
  find_library(RTEMSNFS nfs)
  list(APPEND EPICS_Com_LIBRARY ${RTEMSCPU} ${RTEMSNFS})
  list(APPEND EPICS_LIBRARIES ${RTEMSCPU} ${RTEMSNFS})
  list(APPEND EPICS_IOC_LIBRARIES ${RTEMSCPU} ${RTEMSNFS})
  list(APPEND EPICS_HOST_LIBRARIES ${RTEMSCPU} ${RTEMSNFS})
  find_library(BSPEXT bspExt)
  if(BSPEXT)
    list(APPEND EPICS_Com_LIBRARY ${BSPEXT})
    list(APPEND EPICS_LIBRARIES ${BSPEXT})
    list(APPEND EPICS_IOC_LIBRARIES ${BSPEXT})
    list(APPEND EPICS_HOST_LIBRARIES ${BSPEXT})
  endif()

endif()

find_package_handle_standard_args(EPICS
  VERSION_VAR EPICSBase_VERSION
  REQUIRED_VARS
    EPICS_BASE_DIR
    EPICS_OS_INCLUDE_DIR
    EPICS_Com_LIBRARY EPICS_LIBRARIES
  HANDLE_COMPONENTS
)
