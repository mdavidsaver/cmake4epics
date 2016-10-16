message(STATUS "Basic Examples")

add_executable(hello hello.c)

add_library(hellolibstatic STATIC hello.c)
set_target_properties(hellolibstatic
  PROPERTIES
   OUTPUT_NAME hello
   VERSION 0.1
   PUBLIC_HEADER empty.h
)

epics_install(
  PROGS hello
  LIBS hellolibstatic
)

if(NOT RTEMS)
  add_library(hellolibshare SHARED hello.c)
  set_target_properties(hellolibshare
    PROPERTIES
     OUTPUT_NAME hello
     SOVERSION 0
     VERSION 0.1
  )

  epics_install(
    LIBS hellolibshare
  )
endif()
