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

set(CMAKE_SYSTEM_NAME RTEMS)
set(CMAKE_SYSTEM_PROCESSOR powerpc)
set(CMAKE_SYSTEM_VERSION 4.9)
set(RTEMS_BSP mvme3100)
set(RTEMS_PREFIX /usr)

set(CMAKE_C_COMPILER ${RTEMS_PREFIX}/bin/${CMAKE_SYSTEM_PROCESSOR}-rtems${CMAKE_SYSTEM_VERSION}-gcc)
set(CMAKE_CXX_COMPILER ${RTEMS_PREFIX}/bin/${CMAKE_SYSTEM_PROCESSOR}-rtems${CMAKE_SYSTEM_VERSION}-g++)
set(CMAKE_OBJCOPY ${RTEMS_PREFIX}/bin/${CMAKE_SYSTEM_PROCESSOR}-rtems${CMAKE_SYSTEM_VERSION}-objcopy)

set(RTEMS_BSP_C_FLAGS "-mcpu=powerpc -msoft-float -D__ppc_generic")
set(RTEMS_LDPARTS
  no-dpmem.rel no-mp.rel no-part.rel no-signal.rel
  no-rtmon.rel
)

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
