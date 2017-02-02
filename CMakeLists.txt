CMAKE_MINIMUM_REQUIRED(VERSION 3.0 FATAL_ERROR)

# This sets BOTG_SOURCE_DIR which may be used later.
INCLUDE( "${CMAKE_SOURCE_DIR}/cmake/BOTG_INCLUDE.cmake" )

# Configure the project and call TriBITS when done.
BOTG_ConfigureProject( "${CMAKE_SOURCE_DIR}" )
GLOBAL_SET( ${PROJECT_NAME}_ENABLE_SECONDARY_TESTED_CODE ON )
TRIBITS_PROJECT_ENABLE_ALL()

# Final print of all the variables for inspection.
# For example: -D MATCH_VARIABLE_REGEX:STRING="" will print everything.
#              -D MATCH_VARIABLE_REGEX:STRING="^BootsOnTheGround" will
#                 print all the BootsOnTheGround variables.
#
IF( DEFINED MATCH_VARIABLE_REGEX )
    BOTG_PrintAllVariables("${MATCH_VARIABLE_REGEX}")
ENDIF()
