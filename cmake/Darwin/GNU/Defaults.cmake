# Allow Fortran line lengths to exceed 132 characters.
set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -ffree-line-length-none")
set(CMAKE_Fortran_FLAGS_RELEASE_OVERRIDE "-O3")
