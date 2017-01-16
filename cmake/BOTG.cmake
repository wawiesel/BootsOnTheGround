
#---------------------------------------------------------------------------
FUNCTION( BOTG_ClearCMakeCache keep_cache )
    #quick return if passed anything CMake TRUE
    IF( DEFINED(keep_cache) AND keep_cache )
        RETURN()
    ENDIF()
    MESSAGE(STATUS "[BootsOnTheGround] clearing CMake cache ... ")

    #otherwise we clear the cache
    FILE(GLOB cmake_generated
        "${CMAKE_BINARY_DIR}/CMakeCache.txt"
        "${CMAKE_BINARY_DIR}/cmake_install.cmake"
        "${CMAKE_BINARY_DIR}/CMakeFiles/*"
    )

    FOREACH(file ${cmake_generated})
      IF (EXISTS "${file}")
         FILE(REMOVE_RECURSE "${file}")
         FILE(REMOVE "${file}")
      ENDIF()
    ENDFOREACH()

ENDFUNCTION()
#---------------------------------------------------------------------------
MACRO(BOTG_PrintAllVariables regex)
    get_cmake_property(_variableNames VARIABLES)

    foreach (_variableName ${_variableNames})

        if( _variableName MATCHES "^_")
            CONTINUE()
        endif()

        if( NOT "${regex}" STREQUAL "" )
            if( NOT _variableName MATCHES "${regex}" )
                CONTINUE()
            endif()
        endif()

        message(STATUS "[BootsOnTheGround] ${_variableName}=${${_variableName}}")

    endforeach()

ENDMACRO()

#---------------------------------------------------------------------------

FUNCTION( BOTG_HuntTPL tribits_name headers libs hunter_name hunter_args )

    SET(${tribits_name}_FORCE_HUNTER OFF
      CACHE BOOL "Force hunter download of TPL ${tribits_name}.")

    TRIBITS_TPL_ALLOW_PRE_FIND_PACKAGE( ${tribits_name}  ${tribits_name}_ALLOW_PREFIND)

    MESSAGE( STATUS "[BootsOnTheGround] ${tribits_name}_ALLOW_PREFIND=${${tribits_name}_ALLOW_PREFIND}" )

    IF( ${tribits_name}_ALLOW_PREFIND OR ${tribits_name}_FORCE_HUNTER )

      #vanilla find
      IF( NOT ${tribits_name}_FORCE_HUNTER )
          MESSAGE( STATUS "[BootsOnTheGround] Calling FIND_PACKAGE(${tribits_name} CONFIG) ...")
          FIND_PACKAGE( ${tribits_name} CONFIG QUIET )
          MESSAGE( STATUS "[BootsOnTheGround] Calling FIND_PACKAGE(${tribits_name} CONFIG) ... ${tribits_name}_FOUND=${${tribits_name}_FOUND}")
      ENDIF()

      #use hunter!
      IF( NOT ${tribits_name}_FOUND AND NOT (hunter_name STREQUAL "") )
        SET( hunter_argx "" )
        IF( hunter_name STREQUAL "" )
            LIST(APPEND hunter_argx ${tribits_name})
        ELSE()
            LIST(APPEND hunter_argx ${hunter_name})
        ENDIF()
        LIST(APPEND hunter_argx ${hunter_args} )

        MESSAGE(STATUS "[BootsOnTheGround] Calling hunter_add_package( ${hunter_argx} )...")

        HUNTER_ADD_PACKAGE( ${hunter_argx} )
        FIND_PACKAGE( ${hunter_argx} )

        #no choice but to be successful with hunter
        GLOBAL_SET(${tribits_name}_FOUND TRUE)

        #set global information about where the stuff is, converting names
        #from hunter to tribits.
        FOREACH( type INCLUDE_DIRS LIBRARY_DIRS)
            GLOBAL_SET(${tribits_name}_${type} ${${hunter_name}_${type}})
        ENDFOREACH()

      ENDIF()

      MESSAGE( STATUS "[BootsOnTheGround] PREFIND result of TPL ${tribits_name}_FOUND=${${tribits_name}_FOUND}")

    ENDIF()

    # Third, call TRIBITS_TPL_FIND_INCLUDE_DIRS_AND_LIBRARIES()
    TRIBITS_TPL_FIND_INCLUDE_DIRS_AND_LIBRARIES( ${tribits_name}
      REQUIRED_HEADERS ${headers}
      REQUIRED_LIBS_NAMES ${libs}
    )

    MESSAGE( STATUS "[BootsOnTheGround] FINAL result of TPL ${tribits_name}_FOUND=${${tribits_name}_FOUND}")

ENDFUNCTION()

MACRO( BOTG_InitializeTriBITS TriBITS_dir )

    # Why TriBITS do you blow away my MODULE_PATH?
    SET(save_path ${CMAKE_MODULE_PATH})

    SET(${PROJECT_NAME}_TRIBITS_DIR ${TriBITS_dir}
      CACHE PATH "TriBITS base directory (default assumes in TriBITS source tree).")

    INCLUDE( ${TriBITS_dir}/TriBITS.cmake )
    SET(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH};${save_path}")

    # Default to off because TriBITS complains otherwise.
    SET(TPL_ENABLE_MPI false)
    SET(CMAKE_CXX_STANDARD 11)

ENDMACRO()

FUNCTION(BOTG_PreventInSourceBuilds)
  GET_FILENAME_COMPONENT(srcdir "${CMAKE_SOURCE_DIR}" REALPATH)
  GET_FILENAME_COMPONENT(bindir "${CMAKE_BINARY_DIR}" REALPATH)

  IF("${srcdir}" STREQUAL "${bindir}")
    BOTG_ClearCMakeCache( FALSE )
    MESSAGE(FATAL_ERROR "[BootsOnTheGround] in-source builds are not allowed!")
  ENDIF()
ENDFUNCTION()
