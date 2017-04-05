CMAKE_MINIMUM_REQUIRED(VERSION 3.0 FATAL_ERROR)

# Only the BootsOnTheGround project should turn off bootstrapping.
SET(BOTG_BOOTSTRAP OFF CACHE BOOL INTERNAL)

# Initialize BOTG.
INCLUDE( "${CMAKE_SOURCE_DIR}/cmake/BOTG_INCLUDE.cmake" )

# Setup this project.
botgProject( BOTG )
botgEnd()
