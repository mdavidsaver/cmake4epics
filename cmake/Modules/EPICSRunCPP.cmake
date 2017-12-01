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



function(epics_cpp infile outfile)
  if(EPICS_TARGET_COMPILER STREQUAL msvc)
    execute_process(COMMAND
                     ${CMAKE_CXX_COMPILER} -C -E -I${EPICS_CORE_INCLUDE_DIR} ${CMAKE_CURRENT_LIST_DIR}/EPICSVersion.cmake.in
                    RESULT_VARIABLE result
                    OUTPUT_FILE ${CMAKE_CURRENT_BINARY_DIR}/EPICSVersion.cmake
    )

  elseif(EPICS_TARGET_COMPILER STREQUAL solStudio)
    execute_process(COMMAND
                     ${CMAKE_CXX_COMPILER} -E -I${EPICS_CORE_INCLUDE_DIR} ${CMAKE_CURRENT_LIST_DIR}/EPICSVersion.cmake.in
                    RESULT_VARIABLE result
                    OUTPUT_FILE ${CMAKE_CURRENT_BINARY_DIR}/EPICSVersion.cmake
    )

  else()
    # Assume GCC for anything else
    execute_process(COMMAND
                     ${CMAKE_CXX_COMPILER} -E -I${EPICS_CORE_INCLUDE_DIR} ${CMAKE_CURRENT_LIST_DIR}/EPICSVersion.cmake.in
                    RESULT_VARIABLE result
                    OUTPUT_FILE ${CMAKE_CURRENT_BINARY_DIR}/EPICSVersion.cmake
    )
  endif()
  include(${CMAKE_CURRENT_BINARY_DIR}/EPICSVersion.cmake)
endfunction()
