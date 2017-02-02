#This function is special and needs to be here so it can be part of a
#Bootstrapping operation.
MACRO( BOTG_DownloadExternalProjects external_projects )
    FOREACH( ep ${external_projects} )
        MESSAGE( STATUS "loading external project=${ep}...")
        CONFIGURE_FILE(external/${ep}.in download/${ep}/CMakeLists.txt)
        EXECUTE_PROCESS(COMMAND ${CMAKE_COMMAND} -G "${CMAKE_GENERATOR}"
            . WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/external/download/${ep})
        EXECUTE_PROCESS(COMMAND ${CMAKE_COMMAND} --build
            . WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/external/download/${ep})
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

    GET_FILENAME_COMPONENT(parent_dir ${CMAKE_CURRENT_LIST_DIR} DIRECTORY)
    SET(BOTG_SOURCE_DIR "${parent_dir}" CACHE PATH INTERNAL)

    IF( EXISTS "${BOTG_SOURCE_DIR}" )
        MESSAGE( STATUS "[BootsOnTheGround] using BOTG_SOURCE_DIR=${BOTG_SOURCE_DIR} ... ")
    ELSE()
        MESSAGE( STATUS "[BootsOnTheGround] bootstrapping in...")
        BOTG_DownloadExternalProjects( BootsOnTheGround )
    ENDIF()

ENDIF()

# Includes all the "BootsOnTheGround" (BOTG) functions.
INCLUDE( "${BOTG_SOURCE_DIR}/cmake/BOTG.cmake" )


