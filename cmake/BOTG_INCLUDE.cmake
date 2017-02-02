##
##
##cmake/BOTG_INCLUDE.cmake
##------------------------------------------------------------------------------
##This file is the key file to include from a project's central
##CMakeLists.txt to perform the BootsOnTheGround magic. It even
##bootstraps in a copy of the BootsOnTheGround repo if not found.
##
##.. code-block:: cmake
##

#This function is special and needs to be here so it can be part of a
#Bootstrapping operation.
MACRO( BOTG_DownloadExternalProjects external_projects )
    FOREACH( ep ${external_projects} )
        MESSAGE( STATUS "loading external project=${ep}...")
        SET( dest "${CMAKE_BINARY_DIR}/external/download/${ep}" )
        CONFIGURE_FILE("${CMAKE_SOURCE_DIR}/external/${ep}.in" "${dest}/CMakeLists.txt" )
        EXECUTE_PROCESS(COMMAND ${CMAKE_COMMAND} -G "${CMAKE_GENERATOR}" . WORKING_DIRECTORY "${dest}")
        EXECUTE_PROCESS(COMMAND ${CMAKE_COMMAND} --build . WORKING_DIRECTORY "${dest}")
    ENDFOREACH()
ENDMACRO()

# Use cached value.
IF( DEFINED BOTG_SOURCE_DIR )

    IF( EXISTS "${BOTG_SOURCE_DIR}" )
        MESSAGE( STATUS "[BootsOnTheGround] using cached BOTG_SOURCE_DIR=${BOTG_SOURCE_DIR} ... ")
    ELSE()
        MESSAGE( ERROR "[BootsOnTheGround] cached BOTG_SOURCE_DIR=${BOTG_SOURCE_DIR} does not exist!")
    ENDIF()

# Set the BootsOnTheGround source directory!
ELSE()

    SET(BOTG_SOURCE_DIR "${CMAKE_SOURCE_DIR}/external/BootsOnTheGround" CACHE PATH INTERNAL)

    IF( EXISTS "${BOTG_SOURCE_DIR}" )
        MESSAGE( STATUS "[BootsOnTheGround] using BOTG_SOURCE_DIR=${BOTG_SOURCE_DIR} ... ")
    ELSE()
        MESSAGE( STATUS "[BootsOnTheGround] bootstrapping in...")
        BOTG_DownloadExternalProjects( BootsOnTheGround )
    ENDIF()

ENDIF()

# Includes all the "BootsOnTheGround" (BOTG) functions.
INCLUDE( "${BOTG_SOURCE_DIR}/cmake/BOTG.cmake" )


