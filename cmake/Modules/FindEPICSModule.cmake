# find_epics_module(
#   NAME <modname>
#   IDFILES <arb1> ..]   # arbitrary file used to identify this module
#   [REQUIRED] [QUIET]
#   [DBDS <file1.dbd> ...]
#   [LIBS <lname> ...[   # omit arch specific prefix and suffix (eg. 'lib' and '.so')
#   [BINS <execname> ...]
#   [NO_DEFAULT_PATH]
#   [PATHS </path1> ...]
#   [HOST]
# )
#
# Search for the components of an EPICS modules
#
# At minimum a module must specify at least one IDFILES entry
#
# Requires:
#  EPICS_TARGET_ARCH
#  EPICS_TARGET_CLASS
#  EPICS_TARGET_COMPILER
# or
#  EPICS_HOST_ARCH
#  EPICS_HOST_CLASS
#  EPICS_HOST_COMPILER
#
#
# Sets:
#  <modname>_FOUND
#  <modname>_DIR
#  <modname>_INCLUDE_DIRS
#  <modname>_DBDS
#  <modname>_LIBRARIES
#
#  for specific targets
#
#  <modname>_<execname>_BIN
#  <modname>_<lname>_LIB
#  <modname>_<file1.dbd>_DBD

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

include(CMakeParseArguments)

function(find_epics_module)
  set(options REQUIRED QUIET HOST)
  set(onearg NAME)
  set(manyarg HEADERS DBDS LIBS BINS PATH IDFILES)
  cmake_parse_arguments(FEM "${options}" "${onearg}" "${manyarg}" ${ARGN})

  if(FEM_HOST)
    set(fem_arch ${EPICS_HOST_ARCH})
    set(fem_class ${EPICS_HOST_CLASS})
    set(fem_cmplr ${EPICS_HOST_COMPILER})
  else()
    set(fem_arch ${EPICS_TARGET_ARCH})
    set(fem_class ${EPICS_TARGET_CLASS})
    set(fem_cmplr ${EPICS_TARGET_COMPILER})
  endif()

  find_path(${FEM_NAME}_DIR
    NAMES ${FEM_IDFILES}
    HINTS ENV ${FEM_NAME}_DIR
    PATHS
      ${EPICS_MODULE_PATH}
      ${FEM_PATH}
      ${EPICS_BASE_DIR}/../${FEM_NAME}
      ${EPICS_BASE_DIR}/../modules/${FEM_NAME}
      ${EPICS_BASE_DIR}
    NO_DEFAULT_PATH
    NO_CMAKE_SYSTEM_PATH
    NO_CMAKE_FIND_ROOT_PATH
  )

  set(${FEM_NAME}_INCLUDE_DIRS
    ${${FEM_NAME}_DIR}/include
    ${${FEM_NAME}_DIR}/include/os/${fem_class}
    ${${FEM_NAME}_DIR}/include/compiler/${fem_cmplr}
    PARENT_SCOPE
  )

  set(${FEM_NAME}_DIR "${${FEM_NAME}_DIR}" PARENT_SCOPE)

  # dbd
  foreach(ent IN LISTS FEM_DBDS)
    find_file(${FEM_NAME}_${ent}_DBD ${ent}
      PATHS ${${FEM_NAME}_DIR}/dbd
      NO_DEFAULT_PATH
      NO_CMAKE_SYSTEM_PATH
      NO_CMAKE_FIND_ROOT_PATH
    )
    list(APPEND fem_vars ${FEM_NAME}_${ent}_DBD)
    list(APPEND ${FEM_NAME}_DBDS ${${FEM_NAME}_${ent}_DBD})
  endforeach()

  # libs
  foreach(ent IN LISTS FEM_LIBS)
    find_library(${FEM_NAME}_${ent}_LIB ${ent}
      PATHS ${${FEM_NAME}_DIR}/lib/${fem_arch}
      NO_DEFAULT_PATH
      NO_CMAKE_SYSTEM_PATH
      NO_CMAKE_FIND_ROOT_PATH
    )
    list(APPEND fem_vars ${FEM_NAME}_${ent}_LIB)
    list(APPEND ${FEM_NAME}_LIBRARIES ${${FEM_NAME}_${ent}_LIB})
  endforeach()

  # binaries
  foreach(ent IN LISTS FEM_BINS)
    find_program(${FEM_NAME}_${ent}_BIN ${ent}
      PATHS ${${FEM_NAME}_DIR}/bin/${fem_arch}
      NO_DEFAULT_PATH
      NO_CMAKE_SYSTEM_PATH
      NO_CMAKE_FIND_ROOT_PATH
    )
    list(APPEND fem_vars ${FEM_NAME}_${ent}_BIN)
    list(APPEND ${FEM_NAME}_BINS ${${FEM_NAME}_${ent}_BIN})
  endforeach()

  set(fem_found 1)
  foreach(ent IN LISTS fem_vars)
    if(NOT ${ent})
      set(fem_found 0)
      if(NOT FEM_QUIET)
        message(STATUS " ${ent} = ${${ent}}")
      endif()
    endif()
  endforeach()
  
  set(${FEM_NAME}_FOUND 0)
  if(fem_found)
    set(${FEM_NAME}_FOUND 1)
        message(STATUS " ${FEM_NAME}_FOUND = ${${FEM_NAME}_FOUND}")
  elseif(FEM_REQUIRED)
    message(SEND_ERROR "Missing ${FEM_NAME}")
  endif()

  set(${FEM_NAME}_FOUND ${${FEM_NAME}_FOUND} PARENT_SCOPE)
  set(${FEM_NAME}_DBDS ${${FEM_NAME}_DBDS} PARENT_SCOPE)
  set(${FEM_NAME}_LIBRARIES ${${FEM_NAME}_LIBRARIES} PARENT_SCOPE)
  set(${FEM_NAME}_BINS ${${FEM_NAME}_BINS} PARENT_SCOPE)

  if(${FEM_NAME}_FOUND AND NOT FEM_QUIET)
    message(STATUS "Found ${FEM_NAME}: ${${FEM_NAME}_DIR}")
    message(STATUS " ${FEM_NAME}_INCLUDE_DIRS  ${${FEM_NAME}_INCLUDE_DIRS}")
    message(STATUS " ${FEM_NAME}_LIBRARIES  ${${FEM_NAME}_LIBRARIES}")
    message(STATUS " ${FEM_NAME}_DBDS  ${${FEM_NAME}_DBDS}")
    message(STATUS " ${FEM_NAME}_BINS  ${${FEM_NAME}_BINS}")
    
  elseif(NOT FEM_QUIET)
    message(STATUS "Not found ${FEM_NAME}")
  endif()
endfunction(find_epics_module)
