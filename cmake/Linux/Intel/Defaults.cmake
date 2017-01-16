#provide for line length > 132
#
# This is to provide for mixed compiler suite (gcc/intel) environements
# This is NOT the right way to do this.
# We need to add the capability to pivot on individual compilers
# rather then compiler suites
#
GET_FILENAME_COMPONENT(compiler_name ${CMAKE_CXX_COMPILER} NAME_WE)
IF(${compiler_name} STREQUAL "icpc")
# MESSAGE("Adding -fp-model source to CMAKE_CXX_FLAGS")
SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fp-model source")
ENDIF()
SET(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS}  -names lowercase -fp-model source -fpp -traceback -heap-arrays 100 -assume byterecl")
set(CMAKE_Fortran_FLAGS_RELEASE_OVERRIDE "-O2")
IF(NOT BUILD_SHARED)
   IF(${PROJECT_NAME}_VERBOSE_CONFIGURE)
      MESSAGE(STATUS "Fixing CMake bug with Intel static build")
      MESSAGE(STATUS "Replacing dynamic library: intlc with static library: irc")
   ENDIF()
   LIST(REMOVE_ITEM CMAKE_Fortran_IMPLICIT_LINK_LIBRARIES "intlc")
   LIST(APPEND CMAKE_Fortran_IMPLICIT_LINK_LIBRARIES "irc")
ENDIF()
