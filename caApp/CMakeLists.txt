if(EPICS_TARGET_HOST) # skip for RTEMS/vxWorks

include_directories(
  ${EPICS_INCLUDE_DIRS}
)

add_executable(caget
  caget.c
  tool_lib.c
)
target_link_libraries(caget
  ${EPICS_ca_LIBRARY}
  ${EPICS_Com_LIBRARY}
)
set_target_properties(caget
  PROPERTIES
   LINKER_LANGUAGE CXX
)

install(TARGETS caget
  RUNTIME DESTINATION caApp/bin
)

endif()
