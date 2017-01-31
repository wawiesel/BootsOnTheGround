
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

    #This is necessary to avoid TriBITs thinking we have found libraries when all we have set is
    #the library names. (First noticed with HDF5 on ORNL's Jupiter Linux cluster)
    SET(${tribits_name}_FORCE_PRE_FIND_PACKAGE ON)

    #This is necessary to avoid TriBITs thinking we have found libraries when all we have set is
    #the library names. (First noticed with HDF5 on ORNL's Jupiter Linux cluster)
    SET(${tribits_name}_FORCE_PRE_FIND_PACKAGE ON)

    TRIBITS_TPL_ALLOW_PRE_FIND_PACKAGE( ${tribits_name}  ${tribits_name}_ALLOW_PREFIND)

    MESSAGE( STATUS "[BootsOnTheGround] ${tribits_name}_ALLOW_PREFIND=${${tribits_name}_ALLOW_PREFIND}" )

    IF( ${tribits_name}_ALLOW_PREFIND OR ${tribits_name}_FORCE_HUNTER )

      #vanilla find
      IF( NOT ${tribits_name}_FORCE_HUNTER )
          MESSAGE( STATUS "[BootsOnTheGround] Calling FIND_PACKAGE(${tribits_name} CONFIG) ...")
          FIND_PACKAGE( ${tribits_name} CONFIG QUIET )
          #says it found it but it didn't populate any variables we need
          IF( ${tribits_name}_FOUND )
	      IF( "${${tribits_name}_LIBRARY_DIRS}" STREQUAL "" AND
                  "${${tribits_name}_INCLUDE_DIRS}" STREQUAL "" )
                  SET( ${tribits_name}_FOUND OFF )
              ENDIF()
          ENDIF()
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

        #issue found in: cmake-3.7/Modules/CheckSymbolExists.cmake
        CMAKE_POLICY(PUSH)
        CMAKE_POLICY(SET CMP0054 OLD)
        FIND_PACKAGE( ${hunter_argx} )
        CMAKE_POLICY(POP)

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
    MESSAGE( STATUS "[BootsOnTheGround] initializing TriBITS ..." )

    # Turn off some things here.
    SET(TPL_ENABLE_MPI OFF CACHE BOOL "Turn off MPI by default.")

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

FUNCTION( BOTG_FixupCompilerNames compiler )

    # Fix up compiler names
    IF( compiler STREQUAL "AppleClang" )
        SET( compiler "Clang" PARENT_SCOPE )
    ENDIF()

ENDFUNCTION()

# Processes all the default flags for a single language.
FUNCTION( BOTG_ProcessDefaultFlags lang )

    # This is the compiler name.
    SET( compiler "${CMAKE_${lang}_COMPILER_ID}")
    BOTG_FixUpCompilerNames( compiler )

    # This is a prefix for the files.
    SET( pre "cmake/${lang}/${compiler}" )

    # The first flag_file is language+compiler dependent.
    # The second is language+compiler+operation system dependent.
    FOREACH( flag_file "${pre}/Flags.cmake" "${pre}/${CMAKE_SYSTEM_NAME}/Flags.cmake" )

        # Check both the project path and the BootsOnTheGround path.
        # Project has precendence.
        SET(proj_flags_path "${CMAKE_SOURCE_DIR}/${flag_file}")
        SET(botg_flags_path "${BOTG_SOURCE_DIR}/${flag_file}")

        # Choose which flags to load.
        IF( EXISTS "${proj_flags_path}")
            MESSAGE( STATUS "[BootsOnTheGround] using ${PROJECT_NAME} flags from path='${proj_flags_path}'.")
            INCLUDE( "${proj_flags_path}" )
        ELSEIF( EXISTS "${botg_flags_path}" )
            MESSAGE( STATUS "[BootsOnTheGround] using default BOTG flags from path='${proj_flags_path}'.")
            INCLUDE( "${botg_flags_path}" )
        ELSE()
            MESSAGE( WARNING "[BootsOnTheGround] neither '${proj_flags_path}' or '${botg_flags_path}' was valid--no default flags used!")
        ENDIF()

    ENDFOREACH()
ENDFUNCTION()

# Used inside the Flags.cmake files for convenience.
FUNCTION( BOTG_AddCompilerFlags lang flags )
    STRING(FIND "${CMAKE_${lang}_FLAGS}" "${flags}" position)
    IF( ${position} LESS 0 )
        MESSAGE(STATUS "[BootsOnTheGround] adding flags='${flags}' for lang='${lang}'")
        SET(CMAKE_${lang}_FLAGS "${CMAKE_${lang}_FLAGS} ${flags}" CACHE BOOL "Compiler flags for lang='${lang}'" FORCE)
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

MACRO( BOTG_DefineTPLs )
    GLOBAL_SET( BOTG_TPL_LIST ${ARGV} )
    SET(tpl_def )
    FOREACH( tpl_loc ${ARGV} )
        STRING(REPLACE "/" "" tpl_name ${tpl_loc})
        LIST(APPEND tpl_def ${tpl_name} "${CMAKE_CURRENT_LIST_DIR}/TPLs/${tpl_loc}/FindTPL${tpl_name}.cmake" TT )
    ENDFOREACH()
    TRIBITS_REPOSITORY_DEFINE_TPLS( ${tpl_def} )
ENDMACRO()

MACRO( BOTG_DefineTPLSubPackages )

    # clear TriBITS variables
    SET(SUBPACKAGES_DIRS_CLASSIFICATIONS_OPTREQS )
    SET(LIB_REQUIRED_DEP_PACKAGES)
    SET(LIB_OPTIONAL_DEP_PACKAGES)
    SET(TEST_REQUIRED_DEP_PACKAGES)
    SET(TEST_OPTIONAL_DEP_PACKAGES)
    SET(LIB_REQUIRED_DEP_TPLS)
    SET(LIB_OPTIONAL_DEP_TPLS)
    SET(TEST_REQUIRED_DEP_TPLS)
    SET(TEST_OPTIONAL_DEP_TPLS)

    # setup up the subpackages list
    FOREACH( tpl_loc ${BOTG_TPL_LIST} )
        STRING(REPLACE "/" "" tpl_name ${tpl_loc})
        LIST(APPEND SUBPACKAGES_DIRS_CLASSIFICATIONS_OPTREQS
             "_${tpl_name}" TPLs/${tpl_loc} ST OPTIONAL )
    ENDFOREACH()

ENDMACRO()

MACRO( BOTG_ConfigureProject project_root_dir )

    MESSAGE( STATUS "[BootsOnTheGround] initializing project with root directory=${project_root_dir} ...")

    # Clear the cache unless provided -D KEEP_CACHE:BOOL=ON.
    BOTG_ClearCMakeCache("${KEEP_CACHE}")

    # Enable the hunter gate for downloading/installing TPLs!
    PROJECT("" NONE) #hack to make HunterGate happy
    INCLUDE( "${BOTG_SOURCE_DIR}/cmake/HunterGate.cmake" )

    # Declare **project**.
    INCLUDE( "${project_root_dir}/ProjectName.cmake" )
    MESSAGE( STATUS "[BootsOnTheGround] declared PROJECT_NAME=${PROJECT_NAME} ...")
    PROJECT( ${PROJECT_NAME} C CXX Fortran )

    # Cannot use TriBITS commands until after this statement!
    BOTG_InitializeTriBITS( "${BOTG_SOURCE_DIR}/external/TriBITS/tribits" )

    # Just good practice.
    BOTG_PreventInSourceBuilds()
    SET(${PROJECT_NAME}_ENABLE_TESTS ON CACHE BOOL "Enable all tests by default.")

    # Enable all secondary tested code only if building BootsOnTheGround.
    SET( enable OFF )
    IF( "${PROJECT_NAME}" STREQUAL BootsOnTheGround )
        SET( enable ON )
    ENDIF()
    GLOBAL_SET( BootsOnTheGround_ENABLE_SECONDARY_TESTED_CODE ${enable} )

    # Process default flags for each language.
    BOTG_ProcessDefaultFlags( C )
    BOTG_ProcessDefaultFlags( CXX )
    BOTG_ProcessDefaultFlags( Fortran )

    # TriBITS processing callback.
    TRIBITS_PROJECT_ENABLE_ALL()

ENDMACRO()

MACRO( BOTG_ConfigureSuperPackage package_name )

    MESSAGE( STATUS "[BootsOnTheGround] configuring super package=${package_name} ...")

    TRIBITS_PACKAGE_DECL( ${package_name} )
    TRIBITS_PROCESS_SUBPACKAGES()
    TRIBITS_PACKAGE_DEF()
    TRIBITS_PACKAGE_POSTPROCESS()

ENDMACRO()

MACRO( BOTG_ConfigurePackage package_name src )

    MESSAGE( STATUS "[BootsOnTheGround] configuring simple package=${package_name} ...")

    TRIBITS_PACKAGE( ${package_name} )
    IF( NOT src STREQUAL "" )
        ADD_SUBDIRECTORY( ${src} )
    ENDIF()
    TRIBITS_PACKAGE_POSTPROCESS()

ENDMACRO()

MACRO( BOTG_AddTPL type need name )
    MESSAGE( STATUS "[BootsOnTheGround] adding TPL type=${type} need=${need} name=${name}...")
    TRIBITS_PACKAGE_DEFINE_DEPENDENCIES(
      ${type}_${need}_PACKAGES
        BootsOnTheGround_${name}
    )
    INCLUDE( "${BOTG_SOURCE_DIR}/TPLs/${name}/cmake/Dependencies.cmake" )
ENDMACRO()
