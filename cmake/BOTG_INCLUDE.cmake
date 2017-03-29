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

#This function needs to be here instead of in BOTG.cmake so it can be part of a
#Bootstrapping operation.
MACRO( botgDownloadExternalProjects )
    FOREACH( ep ${ARGN} )
        IF( NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${ep}" )
            MESSAGE( FATAL_ERROR "[BootsOnTheGround] cannot find external project download file=${ep}" )
        ENDIF()
        GET_FILENAME_COMPONENT( dir "${ep}" DIRECTORY )
        GET_FILENAME_COMPONENT( project "${ep}" NAME_WE )
        SET( BOTG_EXTERNAL_SOURCE_DIR_${project} "${CMAKE_CURRENT_SOURCE_DIR}/${dir}/${project}" CACHE PATH INTERNAL)

        SET( dest "${CMAKE_BINARY_DIR}/_DOWNLOAD/${dir}/${project}" )
        MESSAGE( STATUS "[BootsOnTheGround] bootstrapping project ${ep} ... ")

        CONFIGURE_FILE("${CMAKE_CURRENT_SOURCE_DIR}/${ep}" "${dest}/CMakeLists.txt" )
        EXECUTE_PROCESS(COMMAND ${CMAKE_COMMAND} -G "${CMAKE_GENERATOR}" . WORKING_DIRECTORY "${dest}")
        EXECUTE_PROCESS(COMMAND ${CMAKE_COMMAND} --build . WORKING_DIRECTORY "${dest}")
    ENDFOREACH()
ENDMACRO()


# Default to bootstrapping.
SET(BOTG_BOOTSTRAP ON CACHE BOOL INTERNAL)

# If we bootstrap, then set the source directory and update the projects.
IF( BOTG_BOOTSTRAP )
    SET(BOTG_ROOT_DIR "${CMAKE_SOURCE_DIR}/external/BootsOnTheGround" CACHE PATH INTERNAL)
    botgDownloadExternalProjects(
        external/BootsOnTheGround.in
    )
# If we are building BootsOnTheGround itself, it's easy.
ELSEIF( EXISTS "${CMAKE_SOURCE_DIR}/cmake/BOTG_INCLUDE.cmake" )
    SET(BOTG_ROOT_DIR "${CMAKE_SOURCE_DIR}" CACHE PATH INTERNAL)
# Otherwise we need to set the BOTG_ROOT_DIR based on it's location
# from this file.
ELSE()
    SET(BOTG_ROOT_DIR "${CMAKE_CURRENT_LIST_DIR}/.." CACHE PATH INTERNAL)
ENDIF()

MESSAGE( STATUS "[BootsOnTheGround] using BOTG_ROOT_DIR=${BOTG_ROOT_DIR}")

# Includes all the "BootsOnTheGround" (BOTG) functions.
INCLUDE( "${BOTG_ROOT_DIR}/cmake/BOTG.cmake" )


