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
        MESSAGE( ERROR "[BootsOnTheGround] BOTG_SOURCE_DIR=${BOTG_SOURCE_DIR} does not exist!")
    ENDIF()

    # Includes all the "BootsOnTheGround" (BOTG) functions.
    INCLUDE( "${BOTG_SOURCE_DIR}/cmake/BOTG.cmake" )

ENDIF()


