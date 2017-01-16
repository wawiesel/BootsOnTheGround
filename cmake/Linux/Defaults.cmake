SET(flags "-pthread")
MESSAGE(STATUS "[BootsOnTheGround] adding Linux CXX Flags ${flags}")
# add compiler preprocessor
SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${flags}")

#
# Process fortran flags if we have a fortran compiler
#
IF(${PROJECT_NAME}_ENABLE_Fortran)
   INCLUDE(${CMAKE_SOURCE_DIR}/cmake/${CMAKE_SYSTEM_NAME}/${CMAKE_Fortran_COMPILER_ID}/Defaults.cmake)
ENDIF()
