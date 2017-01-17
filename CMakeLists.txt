CMAKE_MINIMUM_REQUIRED(VERSION 3.0 FATAL_ERROR)

# Includes all the "BootsOnTheGround" (BOTG) functions.
INCLUDE( cmake/BOTG.cmake )
    
# Set the BootsOnTheGround source directory!
SET(BOTG_SOURCE_DIR "${CMAKE_CURRENT_LIST_DIR}" CACHE BOOL INTERNAL)

# We enter here if this is a being built as a standalone TriBITS **project**.
IF( NOT TRIBITS_PROCESSING_PACKAGE )

    # Clear the cache unless provided -D KEEP_CACHE:BOOL=ON.
    BOTG_ClearCMakeCache("${KEEP_CACHE}")

    # Enable the hunter gate!
    INCLUDE( cmake/HunterGate.cmake )

    # Declare **project**.
    INCLUDE( ProjectName.cmake )
    PROJECT(${PROJECT_NAME} C CXX Fortran)
    # Perform standard initialization.
    BOTG_InitializeTriBITS( external/TriBITS/tribits )
    BOTG_PreventInSourceBuilds()

    # Default settings.
    SET(${PROJECT_NAME}_ENABLE_TESTS ON CACHE BOOL "Enable all tests by default.")
    BOTG_Setup()
    
    # Process this TriBITS **project**.
    TRIBITS_PROJECT_ENABLE_ALL()

# We enter here when we build this as a TriBITS **package**, including
# when we come through a second pass during TRIBITS_PROJECT_ENABLE_ALL..
ELSE()

    # Declare **package**.
    TRIBITS_PACKAGE_DECL( BootsOnTheGround )
    TRIBITS_PROCESS_SUBPACKAGES()
    TRIBITS_PACKAGE_DEF()
    TRIBITS_PACKAGE_POSTPROCESS()

    # Final print of all the variables for inspection.
    # For example: -D MATCH_VARIABLE_REGEX:STRING="" will print everything.
    #              -D MATCH_VARIABLE_REGEX:STRING="^BootsOnTheGround" will
    #                 print all the BootsOnTheGround variables.
    #
    IF( DEFINED MATCH_VARIABLE_REGEX )
        BOTG_PrintAllVariables("${MATCH_VARIABLE_REGEX}")
    ENDIF()

ENDIF()
