
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

    # Enable TriBITS.
    SET(${PROJECT_NAME}_TRIBITS_DIR ${TriBITS_dir}
      CACHE PATH "TriBITS base directory (default assumes in TriBITS source tree).")
    INCLUDE( ${TriBITS_dir}/TriBITS.cmake )

    # Recover with appended path.
    SET(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH};${save_path}")

ENDMACRO()

FUNCTION(BOTG_PreventInSourceBuilds)
  GET_FILENAME_COMPONENT(srcdir "${CMAKE_SOURCE_DIR}" REALPATH)
  GET_FILENAME_COMPONENT(bindir "${CMAKE_BINARY_DIR}" REALPATH)

  IF("${srcdir}" STREQUAL "${bindir}")
    BOTG_ClearCMakeCache( FALSE )
    MESSAGE(FATAL_ERROR "[BootsOnTheGround] in-source builds are not allowed!")
  ENDIF()
ENDFUNCTION()

# Check if given Fortran source compiles and links into an executable
#
# BOTG_TryCompileFortran(<code> <var> [FAIL_REGEX <fail-regex>])
#  <code>       - source code to try to compile, must define 'program'
#  <var>        - variable to store whether the source code compiled
#  <fail-regex> - fail if test output matches this regex
#
# The following variables may be set before calling this macro to
# modify the way the check is run:
#
#  CMAKE_REQUIRED_FLAGS = string of compile command line flags
#  CMAKE_REQUIRED_DEFINITIONS = list of macros to define (-DFOO=bar)
#  CMAKE_REQUIRED_INCLUDES = list of include directories
#  CMAKE_REQUIRED_LIBRARIES = list of libraries to link
#
# William A. Wieselquist pulled into BOTG from the SCALE repository.
# It had these commits.
#
MACRO( BOTG_TryCompileFortran source var )
    SET(_fail_regex)
    SET(_key)

    # Collect arguments.
    FOREACH(arg ${ARGN})
        IF("${arg}" MATCHES "^(FAIL_REGEX)$")
            SET(_key "${arg}")
        ELSEIF(_key)
            LIST(APPEND _${_key} "${arg}")
        ELSE()
            MESSAGE(FATAL_ERROR "[BootsOnTheGround] Unknown argument:\n  ${arg}\n")
        ENDIF()
    ENDFOREACH()

    # Set definitions.
    SET(defs "-D${var} ${CMAKE_REQUIRED_FLAGS}")

    # Set libraries.
    IF(CMAKE_REQUIRED_LIBRARIES)
        SET(libs "-DLINK_LIBRARIES:STRING=${CMAKE_REQUIRED_LIBRARIES}")
    ELSE()
        SET(libs)
    ENDIF()

    # Set includes.
    IF(CMAKE_REQUIRED_INCLUDES)
        SET(includes "-DINCLUDE_DIRECTORIES:STRING=${CMAKE_REQUIRED_INCLUDES}")
    ELSE()
        SET(includes)
    ENDIF()

    # Set temporary file.
    SET(tempfile "${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeTmp/BOTG_TryCompileFortran.f90")
    FILE(WRITE "${tempfile}" "${source}\n")

    # Try to compile.
    TRY_COMPILE( ${var} "${CMAKE_BINARY_DIR}" "${tempfile}"
      COMPILE_DEFINITIONS
        "${CMAKE_REQUIRED_DEFINITIONS}"
      CMAKE_FLAGS
        "-DCOMPILE_DEFINITIONS:STRING=${defs}"
        "${libs}"
        "${includes}"
      OUTPUT_VARIABLE output
    )

    # Set the output.
    FOREACH(_regex ${_fail_regex})
        IF("${output}" MATCHES "${_regex}")
            SET(${var} 0)
        ENDIF()
    ENDFOREACH()
ENDMACRO()

MACRO (BOTG_CheckCompilerFlagFortran _flag _result)
   SET(save_defs "${CMAKE_REQUIRED_DEFINITIONS}")
   SET(CMAKE_REQUIRED_DEFINITIONS "${_flag}")
   BOTG_TryCompileFortran("
     program main
          print *, \"Hello World\"
     end program main
     " ${_result}
     # Some compilers do not fail with a bad flag
     FAIL_REGEX "unrecognized .*option"                     # GNU
     FAIL_REGEX "ignoring unknown option"                   # MSVC
     FAIL_REGEX "warning D9002"                             # MSVC, any lang
     FAIL_REGEX "[Uu]nknown option"                         # HP
     FAIL_REGEX "[Ww]arning: [Oo]ption"                     # SunPro
     FAIL_REGEX "command option .* is not recognized"       # XL
     )
   SET (CMAKE_REQUIRED_DEFINITIONS "${save_defs}")
ENDMACRO()

MACRO( BOTG_InitializeOptions )

    # Default to off because TriBITS complains otherwise.
    SET(TPL_ENABLE_MPI OFF CACHE BOOL "Turn off MPI by default.")
    SET(CMAKE_CXX_STANDARD 11 CACHE STRING "Set C++11 standard on by default.")
    SET(${PROJECT_NAME}_ENABLE_TESTS ON CACHE BOOL "Enable all tests by default.")
    SET(${PROJECT_NAME}_ENABLE_Fortran OFF CACHE BOOL "Disable fortran by default.")

    # Project wide conflict resolution for windows min/max macro
    # that gets set in "windows.h"
    IF(CMAKE_SYSTEM_NAME MATCHES "Windows")
      ADD_DEFINITIONS(-DNOMINMAX -DNOGDI)
    ENDIF()

    # Include os-specific flags.
    SET(defaults_path "${CMAKE_SOURCE_DIR}/cmake/${CMAKE_SYSTEM_NAME}/Defaults.cmake")
    IF( NOT EXISTS "${defaults_path}")
        MESSAGE( WARNING "[BootsOnTheGround] No Global defaults for ${CMAKE_SYSTEM_NAME}.")
    ELSE()
        INCLUDE( "${defaults_path}" )
    ENDIF()

    # Fortran
    IF(${PROJECT_NAME}_ENABLE_Fortran)
        #
        # Only detect traceback flags
        # if they have not already been set
        #
        IF(NOT CMAKE_Fortran_FLAGS_TRACEBACK)
            SET(TRACEBACK_OPTIONS
                "-fbacktrace" # Standard gcc
                "/traceback"  # Standard intel windows
                "-traceback"  # Standard intel linux
            )
            FOREACH( TOPTION ${TRACEBACK_OPTIONS})
                IF(${PROJECT_NAME}_VERBOSE_CONFIGURE})
                    MESSAGE(STATUS "[BootsOnTheGround] Testing Fortran traceback flag: ${TOPTION}")
                ENDIF()
                BOTG_CheckCompilerFlagFortran("${TOPTION}" CMAKE_Fortran_FLAGS_TRACEBACK_RESULT)
                IF(CMAKE_Fortran_FLAGS_TRACEBACK_RESULT)
                    # CACHE the successful flags
                    SET(CMAKE_Fortran_FLAGS_TRACEBACK "${TOPTION}" CACHE INTERNAL "Fortran traceback flags")

                    # Append compiler flag to CMAKE_Fortran_FLAGS
                    SET(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} ${CMAKE_Fortran_FLAGS_TRACEBACK}")
                    IF(${PROJECT_NAME}_VERBOSE_CONFIGURE})
                        MESSAGE(STATUS "[BootsOnTheGround] Success Fortran traceback flag: ${TOPTION}")
                    ENDIF()
                    BREAK()
                ENDIF()
            ENDFOREACH()
            IF(${PROJECT_NAME}_VERBOSE_CONFIGURE})
                IF(NOT CMAKE_Fortran_FLAGS_TRACEBACK)
                   MESSAGE(WARNING "[BootsOnTheGround] Failed to detect Fortran traceback flag: ${TRACEBACK_OPTIONS}")
                ENDIF()
            ENDIF()
        ELSE()
            SET(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} ${CMAKE_Fortran_FLAGS_TRACEBACK}")
        ENDIF()
    ENDIF()

ENDMACRO()
