#supplement the c flags to ensure c source knows language binding(UPPER w/no underscore)
SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -D_WIN32 -DUPPERCASE -DNOUNDERSCORE")

SET(CUR_DIR ${SCALE_CMAKE_DIR}/${CMAKE_SYSTEM_NAME})

#
# Process fortran flags if we have a fortran compiler
#
IF(${PROJECT_NAME}_ENABLE_Fortran)
   INCLUDE(${CUR_DIR}/${CMAKE_Fortran_COMPILER_ID}/Defaults.cmake)
ENDIF()
