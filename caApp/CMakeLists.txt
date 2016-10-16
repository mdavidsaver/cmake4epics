if(EPICS_TARGET_HOST) # skip for RTEMS/vxWorks

add_executable(caget
  caget.c
  tool_lib.c
)
target_include_directories(caget
  PUBLIC ${EPICS_INCLUDE_DIRS}
  PRIVATE ${EPICS_INCLUDE_DIRS}
  INTERFACE ${EPICS_INCLUDE_DIRS}
)
target_compile_definitions(caget
  PUBLIC ${EPICS_DEFINITIONS}
  PRIVATE ${EPICS_DEFINITIONS}
  INTERFACE ${EPICS_DEFINITIONS}
)
target_link_libraries(caget
  ${EPICS_ca_LIBRARY}
  ${EPICS_Com_LIBRARY}
)
set_target_properties(caget
  PROPERTIES
   LINKER_LANGUAGE CXX
)

epics_install(
  PROGS caget
)

endif()
