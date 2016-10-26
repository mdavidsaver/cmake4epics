#=============================================================================
# Copyright 2015 Brookhaven Science Assoc. as operator of
#                Brookhaven National Lab
# Copyright 2016 Michael Davidsaver
#
# Distributed under the OSI-approved BSD License (the "License");
# see accompanying file LICENSE for details.
#
# This software is distributed WITHOUT ANY WARRANTY; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the License for more information.
#=============================================================================

# use this when building 32-bit on a 64-bit host (eg. with multilib)

set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_VERSION 4)
set(CMAKE_SYSTEM_PROCESSOR "i686")

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -m32"
  CACHE STRING "force flags"
)
set(CMAKE_C_FLAGS   "${CMAKE_C_FLAGS} -m32"
  CACHE STRING "force flags"
)
