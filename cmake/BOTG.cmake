#------------------------------------------------------------------------------
# Set BOTG_DIR
#
GET_FILENAME_COMPONENT( parent_dir "${CMAKE_CURRENT_LIST_DIR}" DIRECTORY )
SET(BOTG_ROOT_DIR "${parent_dir}" CACHE PATH INTERNAL)
MESSAGE( STATUS "[BootsOnTheGround] using BOTG_ROOT_DIR=${BOTG_ROOT_DIR}")
#------------------------------------------------------------------------------
# PUBLIC
# Clear the CMake cache variables.
#
FUNCTION( botgClearCMakeCache keep_cache )
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
#------------------------------------------------------------------------------
# PUBLIC
# Print variables according to a regular expression.
#
MACRO(botgPrintVar regex)
    GET_CMAKE_PROPERTY(_variableNames VARIABLES)

    FOREACH(_variableName ${_variableNames})

        IF( _variableName MATCHES "^_")
            CONTINUE()
        ENDIF()

        IF( NOT "${regex}" STREQUAL "" )
            IF( NOT _variableName MATCHES "${regex}" )
                CONTINUE()
            ENDIF()
        ENDIF()

        MESSAGE(STATUS "[BootsOnTheGround] ${_variableName}=${${_variableName}}")

    ENDFOREACH()
ENDMACRO()
#------------------------------------------------------------------------------
# PUBLIC
# Prevent in-source builds.
#
FUNCTION(botgPreventInSourceBuilds)

  GET_FILENAME_COMPONENT(srcdir "${CMAKE_SOURCE_DIR}" REALPATH)
  GET_FILENAME_COMPONENT(bindir "${CMAKE_BINARY_DIR}" REALPATH)

  IF("${srcdir}" STREQUAL "${bindir}")
    botgClearCMakeCache( FALSE )
    MESSAGE(FATAL_ERROR "[BootsOnTheGround] in-source builds are not allowed!")
  ENDIF()

ENDFUNCTION()
#------------------------------------------------------------------------------
# PUBLIC
# Enforce the minimum compiler version.
#
FUNCTION( botgMinimumCompilerVersion lang compiler min_version )
    botgCompilerMatches( ${lang} ${compiler} found )
    IF( found )
        SET(version "${CMAKE_${lang}_COMPILER_VERSION}")
        IF( "${version}" STREQUAL "" )
            MESSAGE( WARNING "CMAKE_${lang}_COMPILER_VERSION could not be discovered!")
        ELSEIF( CMAKE_${lang}_COMPILER_VERSION VERSION_LESS ${min_version} )
            MESSAGE( FATAL_ERROR "compiler=${compiler} for lang=${lang} is required to have minimum version=${min_version} but found ${version}!")
        ENDIF()
    ENDIF()
ENDFUNCTION()
#------------------------------------------------------------------------------
# PUBLIC
# Use a particular version of the C++ standard.
#
MACRO( botgUseCxxStandard version )
    botgAddCompilerFlags( CXX "GNU|Clang|Intel" ANY_SYSTEM
        "-std=c++${version}"
    )
ENDMACRO()
#------------------------------------------------------------------------------
# PUBLIC
# Use a particular version of the C standard.
#
MACRO( botgUseCStandard version )
    botgAddCompilerFlags( C "GNU|Clang|Intel" ANY_SYSTEM
        "-std=c${version}"
    )
ENDMACRO()
#------------------------------------------------------------------------------
# PUBLIC
# Enable some useful Fortran features.
#
MACRO( botgEnableFortran )
    FOREACH( directive ${ARGN} )
        IF( directive STREQUAL "C_PREPROCESSOR" )
            botgAddCompilerFlags( Fortran "GNU|Clang" ANY_SYSTEM "-cpp" )
        ELSEIF( directive STREQUAL "UNLIMITED_LINE_LENGTH" )
            botgAddCompilerFlags( Fortran "GNU|Clang" ANY_SYSTEM "-ffree-line-length-none" )
        ELSE()
            MESSAGE(FATAL_ERROR "[BootsOnTheGround] EnableFortran directive=${directive} is unknown!")
        ENDIF()
    ENDFOREACH()
ENDMACRO()
#------------------------------------------------------------------------------
# PUBLIC
# Check a flag for a particular language.
#
MACRO( botgCheckFlag lang flag found )
    IF( ${lang} STREQUAL "Fortran" )
        #CMake does not have a core one so we provide above.
        botgCheckFlag_Fortran( "${flag}" ${found} )
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
#------------------------------------------------------------------------------
# PUBLIC
# Add flags to the compiler.
#
MACRO( botgAddCompilerFlags lang compiler system) #list of flags comes at end
    botgCompilerAndSystemMatches( "${lang}" "${compiler}" "${system}" found )
    IF( found )
        #MESSAGE(STATUS "[BootsOnTheGround] adding package=${PACKAGE_NAME} ${lang} flags for compiler='${BOTG_${lang}_COMPILER}' on system='${BOTG_SYSTEM}'")
        FOREACH( flag ${ARGN} )
            #check if flag is already in list
            STRING(FIND "${CMAKE_${lang}_FLAGS}" "${flag}" position)
            IF( ${position} LESS 0 )
                #create a special variable to store whether the flag works
                STRING(REGEX REPLACE "[^0-9a-zA-Z]" "_" flagname ${flag})
                botgCheckFlag( ${lang} ${flag} BOTG_USE_${lang}_FLAG_${flagname})
                IF( BOTG_USE_${lang}_FLAG_${flagname} )
                    MESSAGE(STATUS "[BootsOnTheGround] package=${PACKAGE_NAME} added flag='${flag}' for lang=${lang} for compiler='${BOTG_${lang}_COMPILER}' on system='${BOTG_SYSTEM}'!")
                    SET( CMAKE_${lang}_FLAGS "${CMAKE_${lang}_FLAGS} ${flag}")
                ELSE()
                    MESSAGE(STATUS "[BootsOnTheGround] package=${PACKAGE_NAME} could not add invalid flag='${flag}'!")
                ENDIF()
            ENDIF()
        ENDFOREACH()
    ENDIF()
ENDMACRO()
#------------------------------------------------------------------------------
# PUBLIC
# Define a library (including headers) to build.
# botgLibrary( <name>
#    LANGUAGE <lang>
#    SOURCES
#        <src1>
#        <src2>
#        ...
#    HEADERS
#        <hdr1>
#        <hdr2>
#        ...
#    LINK_TO
#        <lib-target1> <lib-target2>
# )
#
# FLAGS
# - HEADERS - listing of header files to follow
# - SOURCES - listing of source files to follow
# - LANGUAGE - optional language specification <lang>=C|CXX|Fortran
#              For header-only libraries (i.e. empty SOURCES), it is required.
#              If provided, does SET_TARGET_PROPERTIES( <name> PROPERTIES LINKER_LANGUAGE <lang> )
# - LINK_TO - list of library names to apply TARGET_LINK_LIBRARIES
#
MACRO( botgLibrary name )
    # parse arguments
    SET(options)
    SET(one_value_args LANGUAGE )
    SET(multi_value_args LINK_TO SOURCES HEADERS )
    CMAKE_PARSE_ARGUMENTS(library "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN} )

    #determine if language is enabled
    SET(enabled ON)
    IF( NOT "${library_LANGUAGE}" STREQUAL "" )
        IF( "${library_LANGUAGE}" STREQUAL Fortran )
            SET(enabled "${${PROJECT_NAME}_ENABLE_Fortran}" )
        ELSEIF(  "${library_LANGUAGE}" STREQUAL CXX )
            SET(enabled "${${PROJECT_NAME}_ENABLE_CXX}" )
        ELSEIF(  "${library_LANGUAGE}" STREQUAL C )
            SET(enabled "${${PROJECT_NAME}_ENABLE_C}" )
        ELSE()
            MESSAGE( FATAL_ERROR "[BootsOnTheGround] botgLibrary LANGUAGE ${libraryLanguage} is unknown (Fortran|C|CXX)")
        ENDIF()
    ENDIF()

    IF( enabled )

        #set include directories
        TRIBITS_INCLUDE_DIRECTORIES(
            ${CMAKE_CURRENT_SOURCE_DIR}  #For C++
            ${CMAKE_CURRENT_BINARY_DIR}  #For fortran modules/configured files
        )

        #create list of sources
        SET( sources )
        FOREACH( source ${library_SOURCES} )
            IF( EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${source}" )
                SET( source "${CMAKE_CURRENT_SOURCE_DIR}/${source}" )
            ELSEIF( EXISTS "${CMAKE_CURRENT_BINARY_DIR}/${source}" )
                SET( source "${CMAKE_CURRENT_BINARY_DIR}/${source}" )
            ENDIF()
            LIST(APPEND sources "${source}" )
        ENDFOREACH()

        #create list of headers and install directives
        SET( headers )
        FOREACH( header ${library_HEADERS} )
            GET_FILENAME_COMPONENT( dir "${header}" DIRECTORY )
            IF( EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${header}" )
                SET( header "${CMAKE_CURRENT_SOURCE_DIR}/${header}" )
            ELSEIF( EXISTS "${CMAKE_CURRENT_BINARY_DIR}/${header}" )
                SET( header "${CMAKE_CURRENT_BINARY_DIR}/${header}" )
            ENDIF()
            LIST(APPEND headers "${header}" )
            INSTALL(FILES "${header}" DESTINATION "include/${dir}")
        ENDFOREACH()

        #call TriBITS to add a library
        IF( "${sources}" STREQUAL "" )
            MESSAGE(STATUS "[BootsOnTheGround] configuring header-only library=${name}")
            #header-only
            ADD_LIBRARY( ${name}
                INTERFACE
            )
        ELSE()
            #traditional source
            TRIBITS_ADD_LIBRARY( ${name}
                SOURCES
                    "${sources}"
                NOINSTALLHEADERS
                    "${headers}"
            )

            #set properties on target
            IF( NOT "${library_LANGUAGE}" STREQUAL "")
                SET_TARGET_PROPERTIES( ${name} PROPERTIES LINKER_LANGUAGE ${library_LANGUAGE} )
            ENDIF()

        ENDIF()

        #do linking
        FOREACH( link_to ${library_LINK_TO} )
            TARGET_LINK_LIBRARIES( ${name} ${link_to} )
        ENDFOREACH()


    ENDIF()

ENDMACRO()
#------------------------------------------------------------------------------
# PUBLIC
# Add flags to the linker.
#
MACRO( botgAddLinkerFlags compiler system ) #list of flags comes at end
    #Use CXX to check the validity of flags
    botgCompilerAndSystemMatches( CXX "${compiler}" "${system}" found )
    IF( found )
        #MESSAGE(STATUS "[BootsOnTheGround] adding package=${PACKAGE_NAME} flags for linker on system='${BOTG_SYSTEM}'")
        FOREACH( flag ${ARGN} )
            #check if flag is already in list
            STRING(FIND "${CMAKE_EXE_LINKER_FLAGS}" "${flag}" position)
            IF( ${position} LESS 0 )
                #create a special variable to store whether the flag works
                STRING(REGEX REPLACE "[^0-9a-zA-Z]" "_" flagname ${flag})
                botgCheckFlag( CXX ${flag} BOTG_USE_EXE_LINKER_FLAG_${flagname})
                IF( BOTG_USE_EXE_LINKER_FLAG_${flagname} )
                    MESSAGE(STATUS "[BootsOnTheGround] enabled linker flag='${flag}' for compiler=${compiler} on system='${BOTG_SYSTEM}'!")
                    SET( CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${flag}")
                ELSE()
                    MESSAGE(STATUS "[BootsOnTheGround] could not add invalid linker flag='${flag}'!")
                ENDIF()
            ENDIF()
        ENDFOREACH()
    ENDIF()
ENDMACRO()
#------------------------------------------------------------------------------
# PUBLIC
# Return the current git hash
#
FUNCTION( botgGitHash hash )
    EXECUTE_PROCESS(
      COMMAND git log -1 --format=%h
      WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
      OUTPUT_VARIABLE hash_
      OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    SET( ${hash} ${hash_} PARENT_SCOPE )
ENDFUNCTION()
#------------------------------------------------------------------------------
# PUBLIC
# Add test directory
#
MACRO( botgTestDir )
    TRIBITS_ADD_TEST_DIRECTORIES( ${ARGN} )
ENDMACRO()
#------------------------------------------------------------------------------
# PUBLIC
# Resolve version number.
#
MACRO( botgResolveVersion )
    SET(version "UNKNOWN")
    IF( EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/Version.cmake" )
        INCLUDE( "${CMAKE_CURRENT_SOURCE_DIR}/Version.cmake" )
        ASSERT_DEFINED( VERSION )
        SET(version "${VERSION}")
    ENDIF()
    GLOBAL_SET( ${PACKAGE_NAME}_VERSION "${version}")
ENDMACRO()
#------------------------------------------------------------------------------
# PUBLIC (DEPRECATED)
# Set contents of a project/repo. (Eventually will process version numbers of
# packages, too.)
#
# botgProjectContents(
#   PACKAGE_NAME   PACKAGE_LOCATION   PACKAGE_TEST_LEVEL
# )
MACRO( botgProjectContents )
    MESSAGE(WARNING "[BootsOnTheGround] The botgProjectContents MACRO is "
                    "DEPRECATED and will be removed in v0.11.0!"
                    " Use botgPackagesList instead.")
    botgPackagesList( ${ARGN} )
ENDMACRO()
#------------------------------------------------------------------------------
# PUBLIC
# Register the list packages a project uses. This should be placed in the
# project PackagesList.cmake file.
#
# botgPackagesList(
#   PACKAGE_NAME   PACKAGE_LOCATION   PACKAGE_TEST_LEVEL
# )
#
# TODO:
# Process version numbers of packages.
#
MACRO( botgPackagesList )

    #get input length
    SET(local_args0 "${ARGN}")
    LIST(LENGTH local_args0 ntotal)

    #start out with BOTG!
    SET_DEFAULT(BOTG_TEST_LEVEL "ST")
    SET(local_args "BootsOnTheGround;${BOTG_ROOT_DIR}/src;${BOTG_TEST_LEVEL}")
    SET(external_projects)

    #iterate through and reconstruct components
    IF( ntotal GREATER 2 )
        FOREACH(i RANGE 1 ${ntotal} 3)

            #get components
            MATH(EXPR im1 "${i}-1")
            MATH(EXPR ip1 "${i}+1")
            LIST(GET local_args0 "${im1}" pkg)
            LIST(GET local_args0 "${i}"   loc)
            LIST(GET local_args0 "${ip1}" tst)

            #check we don't have a double
            IF( pkg MATCHES "^BootsOnTheGround" )
                MESSAGE(FATAL_ERROR "[BootsOnTheGround] Do not include BootsOnTheGround in the botgPackagesList!")
            ENDIF()

            #######################################################################
            #TODO process special form of package that includes VERSION STRING
            #######################################################################

            #split location into directory components
            #If a directory is actually a .in file then load the external project.
            STRING( REPLACE "/" ";" components ${loc} )
            SET(loc)
            FOREACH( component ${components} )
                IF( component MATCHES "\\.in$" )
                    LIST(APPEND external_projects "${loc}/${component}")
                    STRING(REGEX REPLACE "\\.in" "" component "${component}")
                ENDIF()
                SET(loc "${loc}/${component}")
            ENDFOREACH()
            STRING( REGEX REPLACE "^/" "" loc "${loc}") #remove first /

            #reconstruct full args
            LIST(APPEND local_args ${pkg} ${loc} ${tst})
        ENDFOREACH()
    ENDIF()
    MESSAGE( STATUS "local_args=${local_args}")
    #download any external projects
    botgDownloadExternalProjects(
        ${external_projects}
    )

    #define packages with tribits
    TRIBITS_REPOSITORY_DEFINE_PACKAGES(
        ${local_args}
    )

ENDMACRO()
#------------------------------------------------------------------------------
# PUBLIC
# Register the TPLs a project uses. This should be placed in the
# project TPLsList.cmake file.
#
# botgTPLsList(
#   TPL_NAME   FIND_TPL_LOCATION   TPL_TEST_LEVEL
# )
#
# TODO:
# Process version numbers of TPLS.
#
MACRO( botgTPLsList )

    #get input length
    SET(local_args0 "${ARGN}")
    LIST(LENGTH local_args0 ntotal)

    #accumulate the user TPL list
    SET(tpl_list)
    SET(local_args)
    #iterate through and reconstruct components
    IF( ntotal GREATER 2 )
        FOREACH(i RANGE 1 ${ntotal} 3)

            #get components
            MATH(EXPR im1 "${i}-1")
            MATH(EXPR ip1 "${i}+1")
            LIST(GET local_args0 "${im1}" tpl)
            LIST(GET local_args0 "${i}"   loc)
            LIST(GET local_args0 "${ip1}" tst)

            #######################################################################
            #TODO process special form of TPL that includes VERSION STRING
            #######################################################################

            #create TPL list
            LIST(APPEND tpl_list "${tpl}")

            #reconstruct full args
            LIST(APPEND local_args ${tpl} ${loc} ${tst})
        ENDFOREACH()
    ENDIF()

    #now add the standard TPLs list
    INCLUDE(${BOTG_ROOT_DIR}/src/BOTG_TPLS.cmake)
    FOREACH( tpl_loc ${BOTG_TPLS_LIST} )
        STRING(REPLACE "/" "_" tpl_name ${tpl_loc})
        #only if the user has not registered the name already
        IF( NOT "${tpl_list}" MATCHES ";${tpl_name};" )
            LIST(APPEND local_args ${tpl_name} "${BOTG_ROOT_DIR}/src/${tpl_loc}/FindTPL${tpl_name}.cmake" TT )
        ENDIF()
    ENDFOREACH()

    #now register all TPLs
    TRIBITS_REPOSITORY_DEFINE_TPLS( ${local_args} )

ENDMACRO()
#------------------------------------------------------------------------------
# PUBLIC
# Set contents of a super package.
#
# botgSuperPackageContents(
#   PACKAGE_NAME   PACKAGE_LOCATION   PACKAGE_TEST_LEVEL   OPTIONAL|REQUIRED
# )
MACRO( botgSuperPackageContents )
    # clear TriBITS variables
    SET(LIB_REQUIRED_DEP_PACKAGES)
    SET(LIB_OPTIONAL_DEP_PACKAGES)
    SET(TEST_REQUIRED_DEP_PACKAGES)
    SET(TEST_OPTIONAL_DEP_PACKAGES)
    SET(LIB_REQUIRED_DEP_TPLS)
    SET(LIB_OPTIONAL_DEP_TPLS)
    SET(TEST_REQUIRED_DEP_TPLS)
    SET(TEST_OPTIONAL_DEP_TPLS)
    # set final
    SET(SUBPACKAGES_DIRS_CLASSIFICATIONS_OPTREQS ${ARGN})
ENDMACRO()
#------------------------------------------------------------------------------
# PUBLIC
# Set dependencies. (Eventually will process version numbers of packages too)
#
# botgPackageDependencies(
#   LIB_REQUIRED_PACKAGES ...
#   LIB_OPTIONAL_PACKAGES ...
#   LIB_REQUIRED_TPLS ...
#   LIB_OPTIONAL_TPLS ...
#   TEST_REQUIRED_PACKAGES ...
#   TEST_OPTIONAL_PACKAGES ...
#   TEST_REQUIRED_TPLS ...
#   TEST_OPTIONAL_TPLS ...
# )
MACRO( botgPackageDependencies )
    # parse arguments
    SET(options)
    SET(one_value_args)
    SET(multi_value_args
        LIB_REQUIRED_PACKAGES
        LIB_OPTIONAL_PACKAGES
        TEST_REQUIRED_PACKAGES
        TEST_OPTIONAL_PACKAGES
        LIB_REQUIRED_TPLS
        LIB_OPTIONAL_TPLS
        TEST_REQUIRED_TPLS
        TEST_OPTIONAL_TPLS
    )
    CMAKE_PARSE_ARGUMENTS(depend "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN} )
    #add package
    TRIBITS_PACKAGE_DEFINE_DEPENDENCIES(
        LIB_REQUIRED_PACKAGES    ${depend_LIB_REQUIRED_PACKAGES}
        LIB_OPTIONAL_PACKAGES    ${depend_LIB_OPTIONAL_PACKAGES}
        TEST_REQUIRED_PACKAGES   ${depend_TEST_REQUIRED_PACKAGES}
        TEST_OPTIONAL_PACKAGES   ${depend_TEST_OPTIONAL_PACKAGES}
        LIB_REQUIRED_TPLS        ${depend_LIB_REQUIRED_TPLS}
        LIB_OPTIONAL_TPLS        ${depend_LIB_OPTIONAL_TPLS}
        TEST_REQUIRED_TPLS       ${depend_TEST_REQUIRED_TPLS}
        TEST_OPTIONAL_TPLS       ${depend_TEST_OPTIONAL_TPLS}
    )
    #check if we have a special BootsOnTheGround_ package that also means to
    #add a TPL
    FOREACH( type LIB TEST )
        FOREACH( need REQUIRED OPTIONAL )
            FOREACH( package ${depend_${type}_${need}_PACKAGES} )
                IF( ${package} MATCHES "^BootsOnTheGround_" )
                    STRING(REGEX REPLACE "^BootsOnTheGround_" "" tpl ${package} )
                    APPEND_SET( ${type}_${need}_DEP_TPLS ${tpl} )
                ENDIF()
            ENDFOREACH()
        ENDFOREACH()
    ENDFOREACH()
ENDMACRO()

#------------------------------------------------------------------------------
# PUBLIC
# Do most of the legwork setting up a CMakeLists.txt file for a project.
#
MACRO( botgProject )
    # Clear the cache unless provided -D KEEP_CACHE:BOOL=ON.
    botgClearCMakeCache("${KEEP_CACHE}")

    # Install locally by default.
    IF( CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
        SET( CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/INSTALL" CACHE PATH "default install path" FORCE )
    ENDIF()

    # Enable the hunter gate for downloading/installing TPLs!
    SET(HUNTER_SKIP_LOCK ON)
    PROJECT( "" NONE )
    INCLUDE( "${BOTG_ROOT_DIR}/cmake/HunterGate.cmake" )

    # Load some fundamental identification data.
    INCLUDE( "${CMAKE_SOURCE_DIR}/ProjectName.cmake" )
    IF( NOT DEFINED PROJECT_NAME )
        SET(PROJECT_NAME "MY_PROJECT")
    ENDIF()
    INCLUDE( "${CMAKE_SOURCE_DIR}/Version.cmake" )
    IF( NOT DEFINED PROJECT_VERSION )
        SET(PROJECT_VERSION "0.0.0")
    ENDIF()
    PROJECT( "${PROJECT_NAME}"
        VERSION "${PROJECT_VERSION}"
        LANGUAGES NONE
    )

    # Set variable version strings for TriBITS.
    STRING(REPLACE "." ";" vlist "${PROJECT_VERSION}")
    LIST(GET vlist 0 "${PROJECT_NAME}_MAJOR_VERSION" )

    # Turn off MPI by default.
    SET(TPL_ENABLE_MPI OFF CACHE BOOL "Turn off MPI by default.")

    # Cannot use TriBITS commands until after this statement!
    botgProcessTribits( "${BOTG_ROOT_DIR}/external/TriBITS/tribits" )

    # Just good practice.
    botgPreventInSourceBuilds()

    # Assert when packages are missing by default!
    GLOBAL_SET( ${PROJECT_NAME}_ASSERT_MISSING_PACKAGES ON CACHE BOOL "Assert missing packages by default." )

    # Turn on tests by default.
    GLOBAL_SET( ${PROJECT_NAME}_ENABLE_TESTS ON CACHE BOOL "Enable all tests by default.")

    # Set repository names if not set.
    GLOBAL_SET( REPOSITORY_NAME ${PROJECT_NAME} )

    # These variables make sure we have matching botgEnd() for packages and projects.
    GLOBAL_SET(BOTG_INSIDE_PROJECT_CMAKELISTS "${CMAKE_CURRENT_LIST_FILE}" )
    GLOBAL_SET(BOTG_INSIDE_PACKAGE_CMAKELISTS "" )
    GLOBAL_SET(BOTG_INSIDE_SUPERPACKAGE_CMAKELISTS "" )

    # Set the operating system name so we can have system-dependent flags.
    GLOBAL_SET( BOTG_SYSTEM ${CMAKE_SYSTEM_NAME} )
    MESSAGE( STATUS "[BootsOnTheGround] set operating system global BOTG_SYSTEM=${BOTG_SYSTEM}")

ENDMACRO()
#------------------------------------------------------------------------------
# PUBLIC
# Initialize a super package (package with subpackages) CMakeLists.txt file.
#
MACRO( botgSuperPackage name )
    GLOBAL_SET(BOTG_INSIDE_SUPERPACKAGE_CMAKELISTS "${CMAKE_CURRENT_LIST_FILE}" )
    botgResolveVersion() #macro to resolve the version
    TRIBITS_PACKAGE_DECL( ${name} )
    TRIBITS_PROCESS_SUBPACKAGES()
    TRIBITS_PACKAGE_DEF()
ENDMACRO()
#------------------------------------------------------------------------------
# PUBLIC
# Initialize a package CMakeLists.txt file.
#
MACRO( botgPackage name )
    GLOBAL_SET(BOTG_INSIDE_PACKAGE_CMAKELISTS "${CMAKE_CURRENT_LIST_FILE}" )
    STRING( COMPARE NOTEQUAL "${BOTG_INSIDE_SUPERPACKAGE_CMAKELISTS}" "" is_subpackage )
    IF( ${is_subpackage} )
        #note, subpackages cannot have their own versions
        TRIBITS_SUBPACKAGE( ${name} )
    ELSE()
        botgResolveVersion() #macro to resolve the version
        TRIBITS_PACKAGE( ${name} )
    ENDIF()
    botgProcessTPLS()
ENDMACRO()
#------------------------------------------------------------------------------
# PUBLIC
# Finalize a CMakeLists.txt file.
#
MACRO( botgEnd )
    STRING( COMPARE NOTEQUAL "${BOTG_INSIDE_PACKAGE_CMAKELISTS}" "" is_package )
    STRING( COMPARE NOTEQUAL "${BOTG_INSIDE_SUPERPACKAGE_CMAKELISTS}" "" is_superpackage )
    STRING( COMPARE NOTEQUAL "${BOTG_INSIDE_PROJECT_CMAKELISTS}" "" has_project )

    IF( NOT ${has_project} )
        MESSAGE( FATAL_ERROR "[BootsOnTheGround] botgEnd has been used without a corresponding botgProject in ${CMAKE_CURRENT_LIST_FILE}!" )
    ENDIF()

    #Inside a package/subpackage.
    IF( ${is_package} )
        IF( NOT "${BOTG_INSIDE_PACKAGE_CMAKELISTS}" STREQUAL "${CMAKE_CURRENT_LIST_FILE}" )
            MESSAGE( FATAL_ERROR "[BootsOnTheGround] botEnd has been used without botgPackage!" )
        ENDIF()

        #Inside a subpackage
        IF( ${is_superpackage} )

            ################################
            TRIBITS_SUBPACKAGE_POSTPROCESS()
            ################################
            MESSAGE( STATUS "[BootsOnTheGround] finished configuring subpackage=${PACKAGE_NAME}!")

        #Inside a plain package
        ELSE()

            #############################
            TRIBITS_PACKAGE_POSTPROCESS()
            #############################
            MESSAGE( STATUS "[BootsOnTheGround] finished configuring package=${PACKAGE_NAME} version=${${PACKAGE_NAME}_VERSION}!")

        ENDIF()

        GLOBAL_SET(BOTG_INSIDE_PACKAGE_CMAKELISTS "")

    #Inside a superpackage.
    ELSEIF( ${is_superpackage} )
        IF( NOT "${BOTG_INSIDE_SUPERPACKAGE_CMAKELISTS}" STREQUAL "${CMAKE_CURRENT_LIST_FILE}" )
            MESSAGE( FATAL_ERROR "[BootsOnTheGround] botEnd has been used without botgSuperPackage in ${CMAKE_CURRENT_LIST_FILE}!" )
        ENDIF()

        #############################
        TRIBITS_PACKAGE_POSTPROCESS()
        #############################
        MESSAGE( STATUS "[BootsOnTheGround] finished configuring superpackage=${PACKAGE_NAME} version=${${PACKAGE_NAME}_VERSION}!")

        GLOBAL_SET(BOTG_INSIDE_SUPERPACKAGE_CMAKELISTS "")

    #Inside a project.
    ELSE()

        # Process compiler for each language.
        botgProcessCompiler( C )
        botgProcessCompiler( CXX )
        botgProcessCompiler( Fortran )

        IF( ${is_package} )
            MESSAGE( FATAL_ERROR "[BootsOnTheGround] package=${BOTG_INSIDE_PACKAGE_CMAKELISTS} did not have botgEnd()!" )
        ELSEIF( ${is_superpackage} )
            MESSAGE( FATAL_ERROR "[BootsOnTheGround] super package=${BOTG_INSIDE_SUPERPACKAGE_CMAKELISTS} did not have botgEnd()!" )
        ENDIF()

        ############################
        TRIBITS_PROJECT_ENABLE_ALL()
        ############################

        # Final print of all the variables for inspection.
        # For example: -D MATCH_VARIABLE_REGEX:STRING="" will print everything.
        #              -D MATCH_VARIABLE_REGEX:STRING="^BootsOnTheGround" will
        #                 print all the BootsOnTheGround variables.
        #
        IF( DEFINED MATCH_VARIABLE_REGEX )
            botgPrintVar("${MATCH_VARIABLE_REGEX}")
        ENDIF()

    ENDIF()

ENDMACRO()
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
# PRIVATE
# Process third-party-library (TPL).
#
MACRO( botgProcessTPLS )
    #Linker options always need to be loaded as far as I can tell.
    #Imagine we have true TPL C, and we create BootsOnTheGround wrapper B, and we
    #depend on this package in a code A, A-->B-->C.
    #We can include in the CMake for B the necessary linker options, but what about
    #A? We should be able to "inherit" them from B but I have yet to figure it out
    #without resorting to these types of files.
    FOREACH( name ${${PACKAGE_NAME}_LIB_REQUIRED_DEP_TPLS}
                  ${${PACKAGE_NAME}_LIB_OPTIONAL_DEP_TPLS}
                  ${${PACKAGE_NAME}_TEST_REQUIRED_DEP_TPLS}
                  ${${PACKAGE_NAME}_TEST_OPTIONAL_DEP_TPLS} )
       IF( TPL_ENABLE_${name} )
           STRING(REPLACE "_" "/" path ${name}) #convert name with _ to path with /
           SET( linker_file "${BOTG_ROOT_DIR}/src/${path}/cmake/LinkerFlags.cmake" )
           IF( EXISTS "${linker_file}" )
               MESSAGE( STATUS "[BootsOnTheGround] package=${PACKAGE_NAME} added TPL=${name} file='${linker_file}'")
               INCLUDE( "${linker_file}" )
           ENDIF()
       ENDIF()
    ENDFOREACH()
ENDMACRO()
#------------------------------------------------------------------------------
#---------------------------------------------------------------------------
# PRIVATE
# Hunt down a TPL using hunter.
#
FUNCTION( botgHuntTPL tribits_name headers libs hunter_name hunter_args hunter_find_package )

    SET(${tribits_name}_FORCE_HUNTER OFF
      CACHE BOOL "Force hunter download of TPL ${tribits_name}.")

    #This is necessary to avoid TriBITs thinking we have found libraries when all we have set is
    #the library names. (First noticed with HDF5 on ORNL's Jupiter Linux cluster)
    SET(${tribits_name}_FORCE_PRE_FIND_PACKAGE ON)

    TRIBITS_TPL_ALLOW_PRE_FIND_PACKAGE( ${tribits_name}  ${tribits_name}_ALLOW_PREFIND)

    MESSAGE( STATUS "[BootsOnTheGround] ${tribits_name}_ALLOW_PREFIND=${${tribits_name}_ALLOW_PREFIND}" )

    IF( ${tribits_name}_ALLOW_PREFIND OR ${tribits_name}_FORCE_HUNTER )

      #config find
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

      #use hunter!
      IF( NOT ${tribits_name}_FOUND AND NOT (hunter_name STREQUAL "") )
        SET( hunter_argx "" )
        LIST(APPEND hunter_argx ${hunter_name} )

        #some TPLS have a list of components in hunter
        IF( hunter_args )
          LIST(APPEND hunter_argx COMPONENTS )
          LIST(APPEND hunter_argx ${hunter_args} )
        ENDIF()

        MESSAGE(STATUS "[BootsOnTheGround] Calling hunter_add_package( ${hunter_argx} )...")

        HUNTER_ADD_PACKAGE( ${hunter_argx} )

        #issue found in: cmake-3.7/Modules/CheckSymbolExists.cmake
        CMAKE_POLICY(PUSH)
        CMAKE_POLICY(SET CMP0054 OLD)
        FIND_PACKAGE( ${hunter_name} ${hunter_find_package} ${hunter_args} )
        CMAKE_POLICY(POP)

        #set global information about where the stuff is, converting names
        #from hunter to tribits.
        IF( ${hunter_name}_FOUND )
          FOREACH( type INCLUDE_DIRS LIBRARY_DIRS)
            GLOBAL_SET(${tribits_name}_${type} ${${hunter_name}_${type}})
          ENDFOREACH()
          GLOBAL_SET(${tribits_name}_FOUND TRUE)
        ENDIF()

      ENDIF()

      MESSAGE( STATUS "[BootsOnTheGround] PREFIND result of TPL ${tribits_name}_FOUND=${${tribits_name}_FOUND}")

    ENDIF()

    #Last chance!
    IF( NOT ${tribits_name}_FOUND )
      MESSAGE( STATUS "[BootsOnTheGround] Last chance module mode: FIND_PACKAGE(${tribits_name}) ...")
      FIND_PACKAGE( ${tribits_name} QUIET )
      IF( ${tribits_name}_FOUND )
        GLOBAL_SET(TPL_${tribits_name}_LIBRARIES "${${tribits_name}_LIBRARIES}")
        GLOBAL_SET(TPL_${tribits_name}_INCLUDE_DIRS "")
        GLOBAL_SET(TPL_${tribits_name}_LIBRARY_DIRS "")
      ENDIF()
    ENDIF()

    # Third, call TRIBITS_TPL_FIND_INCLUDE_DIRS_AND_LIBRARIES()
    TRIBITS_TPL_FIND_INCLUDE_DIRS_AND_LIBRARIES( ${tribits_name}
      REQUIRED_HEADERS ${headers}
      REQUIRED_LIBS_NAMES ${libs}
    )

    MESSAGE( STATUS "[BootsOnTheGround] FINAL result of TPL ${tribits_name}_FOUND=${${tribits_name}_FOUND}")

ENDFUNCTION()
#------------------------------------------------------------------------------
# PRIVATE
# Process TriBITS and set TRIBITS_DIR.
#
MACRO( botgProcessTribits TriBITS_dir )
    MESSAGE( STATUS "[BootsOnTheGround] initializing TriBITS ..." )

    # Why TriBITS do you blow away my MODULE_PATH?
    SET(save_path ${CMAKE_MODULE_PATH})

    # Enable TriBITS.
    SET(${PROJECT_NAME}_TRIBITS_DIR ${TriBITS_dir}
      CACHE PATH "TriBITS base directory (default assumes in TriBITS source tree).")
    INCLUDE( ${TriBITS_dir}/TriBITS.cmake )

    # Recover with appended path.
    SET(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH};${save_path}")

ENDMACRO()
#------------------------------------------------------------------------------
# PRIVATE
# Return the compiler variable as "SUITE/COMPILER".
#
FUNCTION( botgGetCompilerName lang compiler )
    SET( compiler_ "${CMAKE_${lang}_COMPILER}")
    GET_FILENAME_COMPONENT(compiler_ "${compiler_}" NAME_WE)
    SET( compiler_suite_ "${CMAKE_${lang}_COMPILER_ID}")
    IF( compiler_suite_ STREQUAL "AppleClang" )
        SET(compiler_suite_ "Clang" )
    ENDIF()
    SET( ${compiler} "${compiler_suite_}/${compiler_}" PARENT_SCOPE )
ENDFUNCTION()
#------------------------------------------------------------------------------
# PRIVATE
# Set the global compiler name BOTG_${lang}_COMPILER="SUITE/COMPILER".
#
MACRO( botgProcessCompiler lang )
    GET_PROPERTY(languages GLOBAL PROPERTY ENABLED_LANGUAGES)
    SET( result OFF )
    IF( ";${languages};" MATCHES ";${lang};" )
        botgGetCompilerName( ${lang} compiler )
        GLOBAL_SET( BOTG_${lang}_COMPILER ${compiler} )
        SET( result ON )
        MESSAGE( STATUS "[BootsOnTheGround] set lang=${lang} compiler global BOTG_${lang}_COMPILER=${BOTG_${lang}_COMPILER}")
    ELSE()
        GLOBAL_SET( BOTG_${lang}_COMPILER "" )
    ENDIF()
    GLOBAL_SET( ${PROJECT_NAME}_ENABLE_${lang} ${result} )
ENDMACRO()
#------------------------------------------------------------------------------
# PRIVATE
# Check if given Fortran source compiles and links into an executable
#
# botgTryCompileFortran(<code> <var> [FAIL_REGEX <fail-regex>])
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
MACRO( botgTryCompileFortran source var )
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
    SET(tempfile "${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeTmp/botgTryCompileFortran.f90")
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
#------------------------------------------------------------------------------
# PRIVATE
# Check a Fortran flag to see if it works.
#
MACRO( botgCheckFlag_Fortran flag result)
   SET(save_defs "${CMAKE_REQUIRED_DEFINITIONS}")
   MESSAGE(STATUS "Performing Test ${flag}")
   SET(CMAKE_REQUIRED_DEFINITIONS "${flag}")
   botgTryCompileFortran("
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
   IF( ${result} )
     MESSAGE(STATUS "Performing Test ${flag} - Success")
   ELSE()
     MESSAGE(STATUS "Performing Test ${flag} - Fail")
   ENDIF()
   SET (CMAKE_REQUIRED_DEFINITIONS "${save_defs}")
ENDMACRO()
#------------------------------------------------------------------------------
# PRIVATE
# Check if the compiler matches. (Used to selectively enable flags.)
#
FUNCTION( botgCompilerMatches lang compiler found )
    SET(${found} OFF PARENT_SCOPE)
    IF( ("${compiler}" STREQUAL "ANY_COMPILER") OR ("${compiler}" STREQUAL "") )
        SET(${found} ON PARENT_SCOPE )
    ELSE()
        STRING(REGEX MATCH "${compiler}" found_ "${BOTG_${lang}_COMPILER}")
        IF( NOT "${found_}" STREQUAL "" )
            SET(${found} ON PARENT_SCOPE)
        ENDIF()
    ENDIF()
ENDFUNCTION()
#------------------------------------------------------------------------------
# PRIVATE
# Check if the system matches. (Used to selectively enable flags.)
#
FUNCTION( botgSystemMatches system found)
    SET(${found} OFF PARENT_SCOPE)
    IF( ("${system}" STREQUAL "ANY_SYSTEM") OR ("${system}" STREQUAL "") )
        SET(${found} ON PARENT_SCOPE )
    ELSE()
        STRING(REGEX MATCH "${system}" found_ "${BOTG_SYSTEM}")
        IF( NOT "${found_}" STREQUAL "" )
            SET(${found} ON PARENT_SCOPE)
        ENDIF()
    ENDIF()
ENDFUNCTION()
#------------------------------------------------------------------------------
# PRIVATE
# Check both compiler and system matches. (Used to selectively enable flags.)
#
FUNCTION( botgCompilerAndSystemMatches lang compiler system found_both)
    botgCompilerMatches( ${lang} ${compiler} found_compiler )
    #MESSAGE(STATUS "[BootsOnTheGround] lang='${lang}' compiler='${compiler}' found='${found_compiler}'")
    botgSystemMatches( ${system} found_system )
    #MESSAGE(STATUS "[BootsOnTheGround] system='${system}' found='${found_system}'")
    IF( found_system AND found_compiler )
        SET(${found_both} ON PARENT_SCOPE )
    ELSE()
        SET(${found_both} OFF PARENT_SCOPE )
    ENDIF()
ENDFUNCTION()
