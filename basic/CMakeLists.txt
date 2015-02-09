message(STATUS "Basic Examples")

add_executable(hello hello.c)

add_library(hellolibstatic STATIC hello.c)
set_target_properties(hellolibstatic
  PROPERTIES
   OUTPUT_NAME hello
   VERSION 0.1
)

install(TARGETS hello hellolibstatic
  ARCHIVE DESTINATION basic/lib
  LIBRARY DESTINATION basic/lib
  RUNTIME DESTINATION basic/bin
  PUBLIC_HEADER DESTINATION basic/include
)

if(NOT RTEMS)
  add_library(hellolibshare SHARED hello.c)
  set_target_properties(hellolibshare
    PROPERTIES
     OUTPUT_NAME hello
     SOVERSION 0
     VERSION 0.1
     PUBLIC_HEADER empty.h
  )

  install(TARGETS hellolibshare
    ARCHIVE DESTINATION basic/lib
    LIBRARY DESTINATION basic/lib
    RUNTIME DESTINATION basic/bin
    PUBLIC_HEADER DESTINATION basic/include
  )
endif()
