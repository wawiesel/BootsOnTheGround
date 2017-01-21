CMAKE_MINIMUM_REQUIRED(VERSION 3.0 FATAL_ERROR)

# Always start with this include OUTSIDE the IF statement below.
# This sets BOTG_SOURCE_DIR.
INCLUDE( "${CMAKE_CURRENT_LIST_DIR}/cmake/BOTG_INCLUDE.cmake" )

# We enter here if this is a being built as a standalone TriBITS **project**.
IF( NOT TRIBITS_PROCESSING_PACKAGE )

    BOTG_ConfigureProject( "${CMAKE_CURRENT_LIST_DIR}" )

# We enter here when we build this as a TriBITS **package**, including
# when we come through a second pass during TRIBITS_PROJECT_ENABLE_ALL.
ELSE()

    BOTG_ConfigureSuperPackage( BootsOnTheGround )

    # Final print of all the variables for inspection.
    # For example: -D MATCH_VARIABLE_REGEX:STRING="" will print everything.
    #              -D MATCH_VARIABLE_REGEX:STRING="^BootsOnTheGround" will
    #                 print all the BootsOnTheGround variables.
    #
    IF( DEFINED MATCH_VARIABLE_REGEX )
        BOTG_PrintAllVariables("${MATCH_VARIABLE_REGEX}")
    ENDIF()

ENDIF()
