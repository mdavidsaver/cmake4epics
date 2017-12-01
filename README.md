# Building EPICS Modules w/ CMake

## User Options

When building a package which provides a CMakeLists.txt using cmake4epics
several options are available.

The location of EPICS Base may be given with the ```EPICS_BASE``` environment variable,
or the ```EPICS_BASE_DIR``` CMake variable.  For example

```cmake
EPICS_BASE=$HOME/epics/base cmake
# or
cmake -DEPICS_BASE_DIR=$HOME/epics/base
```

When not explictly provided, the following locations are checked in order.

```
/usr/lib/epics
/usr/local/epics/base
/usr/local/epics
/opt/epics/base
/opt/epics
```

When the ```find_epics_module(<modname> ...)``` CMake function is used,
the module location may be explicitly given with, for example
```-D<modname>_DIR=$HOME/epics/<modname>```.
An environment variable of the same name is also checked.

When not explictly provided, the following locations are checked in order.

```
${EPICS_MODULE_PATH}
${<modname>_PATH}
${EPICS_BASE_DIR}/../<modname>
${EPICS_BASE_DIR} # will always appear last
```

In certain situations, such as a 32-bit only build on a 64-bit host,
it may be necessary to override the detected Host arch. with
```-DEPICS_HOST_ARCH=<arch-name>```.

The Target arch. can't be overridden explictly, but rather
through a choice of toolchain file and/or CMake generator.
See cross-compiling section below.

## Basic Usage

Place the _cmake/_ sub-directory in the cmake module path
(ie. append to ```${CMAKE_MODULE_PATH}```.

Then use the extra commands, and the variables they define.

For example, if this repository is included as a git submodule as a sub-directory 'c4e'.
Then to link against libca.
See [caApp/CMakeLists.txt](caApp/CMakeLists.txt) for a full example

```cmake
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/c4e/cmake/Modules)
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

## Reporting Problems

When reporting a build failure of _this_ repository,
please include the full output from a clean run of ```cmake``` and
build output (eg. ```make```).

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

Build an IOC executable.

```cmake
epics_add_ioc(<iocname>
  SRCS some.c
  DBDS local.dbd
  LIBS OtherLib  # ${EPICS_IOC_LIBRARIES} is implied
  # NO_INSTALL  # uncomment to skip automatic install
)
```

#### epics\_install(...)

Install to EPICS standard directory layout.

```cmake
epics_install(
  PROGS exetarget  # installed as bin/${EPICS_TARGET_ARCH}/exetarget
  LIBS libtarget   # installed as lib/${EPICS_TARGET_ARCH}/libtarget
  DBDS some.dbd    # installed as dbd/some.dbd
  DBDS some.db     # installed as db/some.db
  INCS some.h      # installed as include/some.h
  OSINCS special.h # installed as include/os/${EPICS_TARGET_CLASS}/special.h
  COMPINCS other.h # installed as include/compiler/${EPICS_TARGET_COMPILER}/other.h
)
````

### find\_package(FindEPICSModule)

#### find\_epics_module(NAME modname ...)

Search for an EPICS "module" (usually a library and .dbd file).

```cmake
find_epics_module(NAME <modname>
  REQUIRED
  QUIET
  IDFILES some.h  # files which must exist
  HEADERS some.h
  DBDS some.dbd
  LIBS libtarget
  BINS someexe
)
```

Defines

* ```${<modname>_FOUND}```
* ```${<modname>_INCLUDE_DIRS}```
* ```${<modname>_<some.dbd>_DBD}``` - for each DBDS
* ```${<modname>_<libtarget>_LIB}``` - for each LIBS
* ```${<modname>_<someexe>_BIN}``` - for each BINS

Search path is

* ```$ENV{<modname>_DIR}```
* ```${EPICS_MODULE_PATH}```
* ```${EPICS_BASE_DIR}/../<modname>/```
* ```${EPICS_BASE_DIR}/```

## "Host" vs. "Target when cross-compiling

In relation to the EPICS Base definitions, the Host arch. is one
which can run on the build host computer.
The Target arch. may be different then the host, and these executables
may not run on the host.

CMake only supports building for a single target at a time.
Host and Target detection implmented in [cmake/FindEPICSHostArch.cmake](cmake/FindEPICSHostArch.cmake)
and [cmake/FindEPICSTargetArch.cmake](cmake/FindEPICSTargetArch.cmake)
is based on what is detected by CMake.

By default CMake builds for the Host, and requires a toolchain file to override this.
Several toolchain files are provided in [toolchains/](toolchains/).

When cross-compiling, the detected Host arch. is used to locate
certain helper programs which must be run as part of the build process.

If necessary the detected Host can be overridden by manually setting
```-DEPICS_HOST_ARCH=<actual-host-arch>```.

The Target can only be changed by specifying a toolchain file,
or generator name (for msvc projects).
Run ```cmake --help``` to see a list of supported generator names.

## Tested configurations

See [.travis.yml](.travis.yml) for auto-tested configurations.

### Linux hosted (x86 or x86_64)

Building on Linux for Linux targets works for 32 and 64-bit targets.
Building for the host is the default behavour of cmake.

### Linux hosted (build x86 on x86_64 host w/ multilib)

Use toolchain file [toolchains/i686-w64-mingw32.cmake](toolchains/linux-x86.cmake).

Note, when EPICS Base has *only* the 32-bit version it is also necessary
to specify ```-DEPICS_HOST_ARCH=linux-x86``` to override the automatic host
arch detection.

### Cross MinGW on Linux

Use MinGW as cross compiler to build Windows executables on a Linux host.
Tested for 32 and 64-bit targets w/ DLL and static build with Base 3.16.

Use toolchain files [toolchains/i686-w64-mingw32.cmake](toolchains/i686-w64-mingw32.cmake)
or [toolchains/x86_64-w64-mingw32.cmake](toolchains/x86_64-w64-mingw32.cmake).

The cross compiler executables are assumed to be in ```$PATH```.

### Cross RTEMS on Linux

Use [toolchains/powerpc-mvme3100-rtems4.9.cmake](toolchains/powerpc-mvme3100-rtems4.9.cmake)
as a template.

### Other

Other configurations have not been tested.
