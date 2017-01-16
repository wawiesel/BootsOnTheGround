#provide for fortran line length's > 132
set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -ffree-line-length-none -cpp -fbacktrace")
set(CMAKE_Fortran_FLAGS_RELEASE_OVERRIDE "-O2 -fbacktrace")
SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -pthread")


