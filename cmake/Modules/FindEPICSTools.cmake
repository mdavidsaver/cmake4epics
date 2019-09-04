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

if(EPICSTools_FIND_REQUIRED)
  # If we can't figure out the target then everything after
  # will fail.  So stop here if we have to.
  find_package(EPICSHostArch REQUIRED)
else()
  find_package(EPICSHostArch)
endif()

find_package(Perl)

set(dbdExpand_NAMES dbExpand dbdExpand.pl)
set(registerRecordDeviceDriver_NAMES
  registerRecordDeviceDriver.pl
)

set(EPICS_TOOLS dbdExpand registerRecordDeviceDriver)

foreach(TOOL ${EPICS_TOOLS})
  find_program(${TOOL} NAMES ${${TOOL}_NAMES}
    PATHS ${EPICS_BASE_DIR}/bin
    PATH_SUFFIXES ${EPICS_HOST_ARCHS}
    NO_DEFAULT_PATH
    NO_CMAKE_SYSTEM_PATH
    NO_CMAKE_FIND_ROOT_PATH
  )
  mark_as_advanced(${TOOL})
endforeach()

find_file(EPICS_MAIN_TEMPLATE EPICSMain.cpp
  PATHS ${CMAKE_CURRENT_LIST_DIR}/../Templates
  NO_DEFAULT_PATH
  NO_CMAKE_SYSTEM_PATH
  NO_CMAKE_FIND_ROOT_PATH
)
mark_as_advanced(EPICS_MAIN_TEMPLATE)

function(epics_ioc_main maincpp)
  add_custom_command(OUTPUT ${maincpp}
    COMMAND ${CMAKE_COMMAND}
    ARGS -E copy_if_different ${EPICS_MAIN_TEMPLATE} ${maincpp}
    DEPENDS ${EPICS_MAIN_TEMPLATE}
  )
endfunction(epics_ioc_main)

function(epics_registerRDD indbd outcpp)
  get_filename_component(basename ${outcpp} NAME_WE)
  if(EPICSBase_VERSION VERSION_GREATER 3.15.0.0)
    add_custom_command(OUTPUT ${outcpp}
      COMMAND ${PERL_EXECUTABLE}
      ARGS ${registerRecordDeviceDriver} -o ${outcpp} ${indbd} ${basename} ${CMAKE_INSTALL_PREFIX}
      DEPENDS ${indbd} ${registerRecordDeviceDriver}
    )
  else()
    add_custom_command(OUTPUT ${outcpp}
      COMMAND ${PERL_EXECUTABLE}
      ARGS ${registerRecordDeviceDriver} ${indbd} ${basename} ${CMAKE_INSTALL_PREFIX} > ${outcpp}
      DEPENDS ${indbd} ${registerRecordDeviceDriver}
    )
  endif()
endfunction(epics_registerRDD)

# Generate an expanded DBD file from a list of component DBD files
#
#epics_expand_dbd outdbd(out.dbd
# INPUTS one.dbd two.dbd
# PATHS /additional/dirs
#)
#
function(epics_expand_dbd outdbd)
  cmake_parse_arguments("" "" "" "INPUTS;PATHS" "${ARGN}")

  list(APPEND _PATHS ${CMAKE_CURRENT_BINARY_DIR})
  list(APPEND _PATHS ${CMAKE_CURRENT_SOURCE_DIR})
  list(APPEND _PATHS ${EPICS_BASE_DIR}/dbd)

  foreach(dir ${_PATHS})
    list(APPEND DBDFLAGS "-I${dir}")
  endforeach(dir)

  foreach(file ${_INPUTS})
    if(IS_ABSOLUTE ${file})
      list(APPEND DBDS ${file})
      get_filename_component(dbddir ${file} DIRECTORY)
      list(APPEND DBDFLAGS "-I${dbddir}")

    else()
      find_file(dbdfile ${file}
        PATHS ${_PATHS}
        NO_DEFAULT_PATH
        NO_CMAKE_SYSTEM_PATH
        NO_CMAKE_FIND_ROOT_PATH
      )
      if(dbdfile)
        list(APPEND DBDS ${dbdfile})
      else()
        message(FATAL_ERROR "Can't find ${file}")
      endif()
      unset(dbdfile CACHE)
    endif()
  endforeach(file)

  set_source_files_properties(${outdbd}
    PROPERTIES GENERATED TRUE
  )

  if(EPICSBase_VERSION VERSION_GREATER 3.15.0.0)
    add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${outdbd}
      COMMAND ${PERL_EXECUTABLE}
      ARGS ${dbdExpand} ${DBDFLAGS} -o ${outdbd} ${DBDS}
      DEPENDS ${dbdExpand} ${DBDS}
    )
  else()
    add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${outdbd}
      COMMAND ${dbdExpand}
      ARGS ${DBDFLAGS} -o ${outdbd} ${DBDS}
      DEPENDS ${dbdExpand} ${DBDS}
    )
  endif()

endfunction(epics_expand_dbd)

# Define an IOC executable and .dbd file
#
# DBDS - List of input .dbd files
# LIBS - Any libraries
# SRCS - Any source files directly inlucded
#
function(epics_add_ioc iocname)
  cmake_parse_arguments("" "NO_INSTALL" "INSTALL_PREFIX" "SRCS;DBDS;LIBS" ${ARGN})
  message(STATUS "IOC ${iocname}")
  message(STATUS " DBDS ${_DBDS}")
  message(STATUS " SRCS ${_SRCS}")
  message(STATUS " LIBS ${_LIBS}")
  message(STATUS " NO_INSTALL ${_NO_INSTALL}")
  message(STATUS " INSTALL_PREFIX ${_INSTALL_PREFIX}")
  if(NOT _DBDS)
    message(SEND_ERROR "IOC ${iocname} needs at least one .dbd file")
  endif()
  epics_expand_dbd(${iocname}.dbd INPUTS base.dbd ${_DBDS})
  epics_registerRDD(${iocname}.dbd ${iocname}_registerRecordDeviceDriver.cpp)
  epics_ioc_main(${iocname}Main.cpp)
  add_executable(${iocname}
    ${iocname}Main.cpp
    ${iocname}_registerRecordDeviceDriver.cpp
    ${_SRCS}
  )
  target_compile_definitions(${iocname}
    PRIVATE ${EPICS_DEFINITIONS}
    PUBLIC  ${EPICS_DEFINITIONS}
    INTERFACE ${EPICS_DEFINITIONS}
  )
  target_link_libraries(${iocname} ${EPICS_IOC_LIBRARIES} ${_LIBS})
  if(NOT _NO_INSTALL)
    epics_install(
      PROGS ${iocname}
      DBDS ${CMAKE_CURRENT_BINARY_DIR}/${iocname}.dbd
      PREFIX ${_INSTALL_PREFIX}
    )
  endif()
endfunction(epics_add_ioc)

function(epics_install)
  cmake_parse_arguments("" "" "PREFIX" "PROGS;LIBS;INCS;OSINCS;COMPINCS;DBDS;DBS;PROTOS" "${ARGN}")
  if(_PROGS OR _LIBS)
    install(TARGETS ${_PROGS} ${_LIBS}
      RUNTIME DESTINATION ${_PREFIX}bin/${EPICS_TARGET_ARCH}
      LIBRARY DESTINATION ${_PREFIX}lib/${EPICS_TARGET_ARCH}
      ARCHIVE DESTINATION ${_PREFIX}lib/${EPICS_TARGET_ARCH}
      PUBLIC_HEADER DESTINATION ${PREFIX}include
    )
  endif()
  if(_INCS)
    install(FILES ${_INCS} DESTINATION ${_PREFIX}/include)
  endif()
  if(_OSINCS)
    install(FILES ${_OSINCS} DESTINATION ${_PREFIX}/include/os/${EPICS_TARGET_CLASS})
  endif()
  if(_COMPINCS)
    install(FILES ${_COMPINCS} DESTINATION ${_PREFIX}/include/compiler/${EPICS_TARGET_COMPILER})
  endif()
  if(_DBDS)
    install(FILES ${_DBDS} DESTINATION ${_PREFIX}dbd)
  endif()
  if(_DBS)
    install(FILES ${_DBS} DESTINATION ${_PREFIX}db)
  endif()
  if(_PROTOS)
    install(FILES ${_PROTOS} DESTINATION ${_PREFIX}protocol)
  endif()
endfunction(epics_install)

find_package_handle_standard_args(EPICSTools
  REQUIRED_VARS
    ${EPICS_TOOLS}
    PERL_EXECUTABLE
)
