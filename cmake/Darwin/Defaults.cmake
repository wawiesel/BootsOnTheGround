SET(flags )
MESSAGE(STATUS "[BootsOnTheGround] adding Darwin CXX Flags ${flags}")

#
# Change fortran compiler flags if we have fortran compiler
#
IF(${PROJECT_NAME}_ENABLE_Fortran)
   #add compiler preprocessor
   SET(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -cpp")
   INCLUDE(${CMAKE_SOURCE_DIR}/cmake/${CMAKE_SYSTEM_NAME}/${CMAKE_Fortran_COMPILER_ID}/Defaults.cmake)
ENDIF()
