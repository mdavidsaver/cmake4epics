include_directories(
  ${EPICS_INCLUDE_DIRS}
)

epics_add_ioc(simple
 DBDS system.dbd example.dbd
 SRCS counter.c
)

include(FindEPICSModule)

find_epics_module(
  NAME autosave
  IDFILES dbd/asSupport.dbd
  DBDS asSupport.dbd
  LIBS autosave
)

find_epics_module(
  NAME asyn
  IDFILES include/asynDriver.h
  DBDS asyn.dbd
  LIBS asyn
)

find_epics_module(
  NAME motor
  IDFILES include/motorRecord.h
  DBDS motorSupport.dbd
  LIBS motor
)

if(asyn_FOUND AND motor_FOUND)
  message(STATUS "Building asyn example IOC")

  include_directories(
    ${asyn_INCLUDE_DIRS}
  )

  epics_add_ioc(softAsyn
    DBDS ${asyn_DBDS} ${motor_DBDS} ${autosave_DBDS}
    LIBS ${motor_LIBRARIES} ${asyn_LIBRARIES} ${autosave_LIBRARIES}
  )

endif()
