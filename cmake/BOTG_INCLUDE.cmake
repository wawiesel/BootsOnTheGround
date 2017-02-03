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


# Set the source directory and update the projects.
SET(BOTG_SOURCE_DIR "${CMAKE_SOURCE_DIR}/external/BootsOnTheGround" CACHE PATH INTERNAL)
BOTG_DownloadExternalProjects(
    BootsOnTheGround
)


# Includes all the "BootsOnTheGround" (BOTG) functions.
INCLUDE( "${BOTG_SOURCE_DIR}/cmake/BOTG.cmake" )


