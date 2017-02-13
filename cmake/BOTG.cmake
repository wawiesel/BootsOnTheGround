#-------------------------------------------------------------------------------
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
#-------------------------------------------------------------------------------
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
#-------------------------------------------------------------------------------
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
#-------------------------------------------------------------------------------
FUNCTION(BOTG_PreventInSourceBuilds)
  GET_FILENAME_COMPONENT(srcdir "${CMAKE_SOURCE_DIR}" REALPATH)
  GET_FILENAME_COMPONENT(bindir "${CMAKE_BINARY_DIR}" REALPATH)

  IF("${srcdir}" STREQUAL "${bindir}")
    BOTG_ClearCMakeCache( FALSE )
    MESSAGE(FATAL_ERROR "[BootsOnTheGround] in-source builds are not allowed!")
  ENDIF()
ENDFUNCTION()
#-------------------------------------------------------------------------------
FUNCTION( BOTG_FixupCompilerNames compiler )

    # Fix up compiler names
    IF( compiler STREQUAL "AppleClang" )
        SET( compiler "Clang" PARENT_SCOPE )
    ENDIF()

ENDFUNCTION()
#-------------------------------------------------------------------------------
# Processes all the default flags for a single language.
MACRO( BOTG_ProcessDefaultFlags lang )

    # Set the compiler name so we can have compiler-dependent flags.
    SET( compiler "${CMAKE_${lang}_COMPILER_ID}")
    BOTG_FixUpCompilerNames( compiler )
    GLOBAL_SET( BOTG_${lang}_COMPILER ${compiler} )
    MESSAGE( STATUS "[BootsOnTheGround] BOTG_${lang}_COMPILER=${BOTG_${lang}_COMPILER}")

ENDMACRO()
#-------------------------------------------------------------------------------
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
#-------------------------------------------------------------------------------
MACRO( BOTG_CheckFortranFlag flag result)
   SET(save_defs "${CMAKE_REQUIRED_DEFINITIONS}")
   SET(CMAKE_REQUIRED_DEFINITIONS "${flag}")
   BOTG_TryCompileFortran("
     program main
          print *, \"Hello World\"
     end program main
     " ${result}
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
#-------------------------------------------------------------------------------
MACRO( BOTG_UseCxxStandard version )
    IF( CMAKE_VERSION VERSION_LESS "3.1" )
        BOTG_AddCompilerFlags( CXX "GNU|Clang" ANY
            "-std=c++${version}"
        )
    ELSE()
        SET(CMAKE_CXX_STANDARD ${version})
    ENDIF()
ENDMACRO()
#-------------------------------------------------------------------------------
MACRO( BOTG_CheckCompilerFlag lang flag found )
    IF( ${lang} STREQUAL "Fortran" )
        #CMake does not have a core one so we provide above.
        BOTG_CheckFortranFlag( "${flag}" ${found} )
    ELSEIF( ${lang} STREQUAL "CXX" )
        INCLUDE(CheckCXXCompilerFlag)
        CHECK_CXX_COMPILER_FLAG("${flag}" ${found})
    ELSEIF( ${lang} STREQUAL "C" )
        INCLUDE(CheckCCompilerFlag)
        CHECK_C_COMPILER_FLAG("${flag}" ${found})
    ELSE()
        MESSAGE(FATAL_ERROR "[BootsOnTheGround] lang=${lang} is not known!" )
    ENDIF()
ENDMACRO()
#-------------------------------------------------------------------------------
MACRO( BOTG_AddCompilerFlags lang compiler system) #list of flags comes at end
    IF( NOT ${compiler} STREQUAL "ANY" )
        STRING(REGEX MATCH "${compiler}" found_compiler ${BOTG_${lang}_COMPILER})
    ELSE()
        SET(found_compiler "ANY")
    ENDIF()
    IF( NOT ${system} STREQUAL "ANY" )
        STRING(REGEX MATCH "${system}" found_system ${BOTG_SYSTEM})
    ELSE()
        SET(found_system "ANY")
    ENDIF()

    IF( (NOT ${found_system} STREQUAL "") AND (NOT ${found_compiler} STREQUAL "") )
        MESSAGE(STATUS "[BootsOnTheGround] adding package=${PACKAGE_NAME} ${lang} flags for system='${found_system}' AND compiler='${found_compiler}'")
        FOREACH( flag ${ARGN} )
            #check if flag is already in list
            STRING(FIND "${CMAKE_${lang}_FLAGS}" "${flag}" position)
            IF( ${position} LESS 0 )
                #create a special variable to store whether the flag works
                STRING(REGEX REPLACE "[^0-9a-zA-Z]" "_" flagname ${flag})
                BOTG_CheckCompilerFlag( ${lang} ${flag} BOTG_USE_${lang}_FLAG_${flagname})
                IF( BOTG_USE_${lang}_FLAG_${flagname} )
                    MESSAGE(STATUS "[BootsOnTheGround] enabled flag='${flag}'!")
                    SET( CMAKE_${lang}_FLAGS "${CMAKE_${lang}_FLAGS} ${flag}")
                ELSE()
                    MESSAGE(STATUS "[BootsOnTheGround] could not add invalid flag='${flag}'!")
                ENDIF()
            ENDIF()
        ENDFOREACH()
    ENDIF()
ENDMACRO()
#-------------------------------------------------------------------------------
MACRO( BOTG_ConfigureProject project_root_dir )
    MESSAGE( STATUS "[BootsOnTheGround] initializing project with root directory=${project_root_dir} ...")

    # Clear the cache unless provided -D KEEP_CACHE:BOOL=ON.
    BOTG_ClearCMakeCache("${KEEP_CACHE}")

    # Install locally by default.
    IF( CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
        SET( CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/INSTALL" CACHE PATH "default install path" FORCE )
    ENDIF()

    # Enable the hunter gate for downloading/installing TPLs!
    PROJECT("" NONE) #hack to make HunterGate happy
    SET(HUNTER_SKIP_LOCK ON)
    INCLUDE( "${BOTG_SOURCE_DIR}/cmake/HunterGate.cmake" )

    # Declare **project**.
    INCLUDE( "${project_root_dir}/ProjectName.cmake" )
    MESSAGE( STATUS "[BootsOnTheGround] declared PROJECT_NAME=${PROJECT_NAME} ...")
    PROJECT( ${PROJECT_NAME} C CXX Fortran )

    # Cannot use TriBITS commands until after this statement!
    BOTG_InitializeTriBITS( "${BOTG_SOURCE_DIR}/external/TriBITS/tribits" )

    # Just good practice.
    BOTG_PreventInSourceBuilds()
    GLOBAL_SET(${PROJECT_NAME}_ENABLE_TESTS ON CACHE BOOL "Enable all tests by default.")

    # Set the operating system name so we can have system-dependent flags.
    GLOBAL_SET( BOTG_SYSTEM ${CMAKE_SYSTEM_NAME} )
    MESSAGE( STATUS "[BootsOnTheGround] BOTG_SYSTEM=${BOTG_SYSTEM}")

    # Process default flags for each language.
    BOTG_ProcessDefaultFlags( C )
    BOTG_ProcessDefaultFlags( CXX )
    BOTG_ProcessDefaultFlags( Fortran )

ENDMACRO()
#-------------------------------------------------------------------------------
MACRO( BOTG_DefineTPLDependencies lib_required_tpls test_required_tpls)

    #Append to existing if we are using BOTG_AddTPL.
    IF( BOTG_APPEND_TPLS )
        #Make sure these are defined.
        APPEND_SET(REGRESSION_EMAIL_LIST)
        APPEND_SET(SUBPACKAGES_DIRS_CLASSIFICATIONS_OPTREQS)
        APPEND_SET(LIB_REQUIRED_DEP_PACKAGES)
        APPEND_SET(LIB_OPTIONAL_DEP_PACKAGES)
        APPEND_SET(TEST_REQUIRED_DEP_PACKAGES)
        APPEND_SET(TEST_OPTIONAL_DEP_PACKAGES)
        APPEND_SET(LIB_OPTIONAL_DEP_TPLS)
        APPEND_SET(TEST_OPTIONAL_DEP_TPLS)

        #Actually set these.
        APPEND_SET(  LIB_REQUIRED_DEP_TPLS  ${lib_required_tpls} )
        APPEND_SET( TEST_REQUIRED_DEP_TPLS ${test_required_tpls} )
    ELSE()
        TRIBITS_PACKAGE_DEFINE_DEPENDENCIES(
           LIB_REQUIRED_TPLS  ${lib_required_tpls}
          TEST_REQUIRED_TPLS ${test_required_tpls}
        )
    ENDIF()

ENDMACRO()
#-------------------------------------------------------------------------------
MACRO( BOTG_AddTPL type need name )

    MESSAGE( STATUS "[BootsOnTheGround] adding TPL type=${type} need=${need} name=${name}...")

    #Make sure TPL name is correct.
    ASSERT_DEFINED(BootsOnTheGround_${name}_SOURCE_DIR)

    #Add dependency on BOTG version of TPL.
    APPEND_SET( ${type}_${need}_DEP_PACKAGES BootsOnTheGround_${name} )

    #Add true TPL dependencies.
    SET(BOTG_APPEND_TPLS ON)
    INCLUDE( "${BOTG_SOURCE_DIR}/src/${name}/cmake/Dependencies.cmake" )
    SET(BOTG_APPEND_TPLS)

ENDMACRO()
#-------------------------------------------------------------------------------
