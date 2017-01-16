SET(CUR_DIR ${SCALE_CMAKE_DIR}/${CMAKE_SYSTEM_NAME})

#
# Change fortran compiler flags if we have fortran compiler
#
IF(${PROJECT_NAME}_ENABLE_Fortran)
   #add compiler preprocessor
   SET(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -cpp")

   INCLUDE(${CUR_DIR}/${CMAKE_Fortran_COMPILER_ID}/Defaults.cmake)
ENDIF()
