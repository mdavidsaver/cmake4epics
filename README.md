# Building EPICS Modules w/ CMake

## Basic Usage

Place the _cmake/_ sub-directory in the cmake module path
(ie. append to ```${CMAKE_MODULE_PATH}```.

Then use the extra commands, and the variables they define.

For example, if this repository is included as a git submodule as a sub-directory 'c4e'.
Then to link against libca.
See [caApp/CMakeLists.txt](caApp/CMakeLists.txt) for a full example

```cmake
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/c4e/cmake)
find_package(EPICS COMPONENTS ca) # Com is implied
add_executable(myexe ...source files...)
target_compile_definitions(myexe
  PUBLIC ${EPICS_DEFINITIONS}
  PRIVATE ${EPICS_DEFINITIONS}
  INTERFACE ${EPICS_DEFINITIONS}
)
target_include_directories(myexe
  PUBLIC ${EPICS_INCLUDE_DIRS}
  PRIVATE ${EPICS_INCLUDE_DIRS}
  INTERFACE ${EPICS_INCLUDE_DIRS}
)
target_link_libraries(myexe
  ${EPICS_ca_LIBRARY}
  ${EPICS_Com_LIBRARY}
)
```

## Commands

### find\_package(EPICS ...)

Find EPICS Base components.
With no additional arguments finds only libCom.
Use COMPONENTS keywords to list additional libraries.

```cmake
find_package(EPICS COMPONENTS ca) # Com is implied
```

Finds libca and libCom.

In addition to the library names, two pseudo library names IOC and HOST
may be given to mimic ```${EPICS_BASE_IOC_LIBS}``` and ```${EPICS_BASE_HOST_LIBS}```.

This package defines:

* ```EPICS_FOUND```
* ```EPICS_BASE_DIR```
* ```EPICS_INCLUDE_DIRS``` - All include directories (common, OS, and compiler)
* ```EPICS_LIB_DIR```
* ```EPICS_LIBRARIES```
* ```EPICS_DEFINITIONS```
* ```EPICS_<lib>_LIBRARY``` - For each component and Com
* ```EPICS_CORE_INCLUDE_DIR```
* ```EPICS_OS_INCLUDE_DIR```
* ```EPICS_COMP_INCLUDE_DIR``` - >=3.15 only
* ```EPICS_TARGET_HOST```` - True except for RTEMS/vxWorks

### find\_package(EPICSTools)

Defines some functions for common operations.
See [iocApp/CMakeLists.txt](iocApp/CMakeLists.txt) for example usage.

#### epics\_add_ioc(iocname ...)

#### find\_epics_module(NAME modname ...)

#### epics\_install(...)

## Tested configurations

See [.travis.yml](.travis.yml) for auto-tested configurations.

### Linux hosted

Building on Linux for Linux targets works for 32 and 64-bit targets.
Building for the host is the default behavour of cmake.

### Cross MinGW on Linux

Use MinGW as cross compiler to build Windows executables on a Linux host.
Tested for 32 and 64-bit targets w/ DLL and static build with Base 3.16.
