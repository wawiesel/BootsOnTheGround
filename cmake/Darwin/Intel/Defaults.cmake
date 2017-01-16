
#provide for no common symbols
SET(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -fno-common")
#provide for line length > 132
SET(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -free")
set(CMAKE_Fortran_FLAGS_RELEASE_OVERRIDE "-O2")
