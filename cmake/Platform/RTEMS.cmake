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

# RTEMS does not support shared libraries
set_property(GLOBAL PROPERTY TARGET_SUPPORTS_SHARED_LIBS FALSE)

# The Toolchain file must specify
# CMAKE_SYSTEM_PROCESSOR as on of
#   i.86
#   powerpc
# CMAKE_SYSTEM_VERSION with the RTEMS version of the tools
# RTEMS_BSP with a valid BSP name
# RTEMS_PREFIX location of tools
#
# eg
#
# set(CMAKE_SYSTEM_NAME RTEMS)
# set(CMAKE_SYSTEM_PROCESSOR powerpc)
# set(CMAKE_SYSTEM_VERSION 4.9)
# set(RTEMS_PREFIX "/usr")
# set(RTEMS_BSP mvme3100)

set(CMAKE_EXECUTABLE_SUFFIX ".elf")

set(RTEMS_TARGET_PREFIX "${RTEMS_PREFIX}/${CMAKE_SYSTEM_PROCESSOR}-rtems${CMAKE_SYSTEM_VERSION}")

set(CMAKE_FIND_ROOT_PATH
  "${RTEMS_TARGET_PREFIX}/${RTEMS_BSP}"
  "${RTEMS_TARGET_PREFIX}"
)
set(CMAKE_SYSTEM_PREFIX_PATH ${CMAKE_FIND_ROOT_PATH})

set(CMAKE_SYSTEM_INCLUDE_PATH
  "${RTEMS_TARGET_PREFIX}/${RTEMS_BSP}/include"
  "${RTEMS_TARGET_PREFIX}/include"
)
set(CMAKE_C_IMPLICIT_INCLUDE_DIRECTORIES ${CMAKE_SYSTEM_INCLUDE_PATH})
set(CMAKE_CXX_IMPLICIT_INCLUDE_DIRECTORIES ${CMAKE_SYSTEM_INCLUDE_PATH})

set(CMAKE_PLATFORM_IMPLICIT_LINK_DIRECTORIES
  "${RTEMS_TARGET_PREFIX}/${RTEMS_BSP}/lib"
)
set(CMAKE_SYSTEM_LIBRARY_PATH ${CMAKE_PLATFORM_IMPLICIT_LINK_DIRECTORIES})

set(CMAKE_C_FLAGS_INIT
 "-B${RTEMS_TARGET_PREFIX}/${RTEMS_BSP}/lib/ -specs bsp_specs -qrtems ${RTEMS_BSP_C_FLAGS}"
)
set(CMAKE_C_FLAGS_INIT ${CMAKE_C_FLAGS_INIT})

set(CMAKE_EXE_LINKER_FLAGS "-u Init")
foreach(ldpart ${RTEMS_LDPARTS})
  set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${RTEMS_TARGET_PREFIX}/${RTEMS_BSP}/lib/${ldpart}")
endforeach()
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -static")

set(RTEMS TRUE)
set(UNIX TRUE)
