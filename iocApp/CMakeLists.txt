include_directories(
  ${EPICS_INCLUDE_DIRS}
)

epics_add_ioc(simple
 DBDS softIoc.dbd example.dbd
 SRCS counter.c
 INSTALL_PREFIX iocApp/
)
