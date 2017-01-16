SET(CUR_DIR ${SCALE_CMAKE_DIR}/${CMAKE_SYSTEM_NAME})

#add compiler preprocessor
SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -pthread")

#
# Process fortran flags if we have a fortran compiler
#
IF(${PROJECT_NAME}_ENABLE_Fortran)
   INCLUDE(${CUR_DIR}/${CMAKE_Fortran_COMPILER_ID}/Defaults.cmake)
ENDIF()
