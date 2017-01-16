##---------------------------------------------------------------------------##
## cmake/CallbackSetupExtraOptions.cmake
## Thomas M. Evans, Seth Johnson, Jordan Lefebvre
## Wednesday January 8 13:18:13 2014
## modified by William A. Wieselquist on January 14, 2017
## to remove SCALE-specific parts
##---------------------------------------------------------------------------##

MACRO(TRIBITS_REPOSITORY_SETUP_EXTRA_OPTIONS)
  ########################################
  # C++11
  ########################################

  # Set CXX11 to be enabled by default.
  SET(${PROJECT_NAME}_ENABLE_CXX11_DEFAULT TRUE)


  ########################################
  # STATIC/SHARED BUILD SETUP
  ########################################

  # Add install RPATH when building shared
  IF(BUILD_SHARED_LIBS AND CMAKE_INSTALL_PREFIX)
    SET(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib")
    SET(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)
    IF (CMAKE_SYSTEM_NAME STREQUAL "Darwin")
      SET(CMAKE_INSTALL_RPATH "@loader_path/../lib")
      IF(POLICY CMP0042)
        SET(CMAKE_MACOSX_RPATH ON)
        SET(CMAKE_SKIP_BUILD_RPATH FALSE)
        SET(CMAKE_BUILD_WITH_INSTALL_RPATH FALSE)
      ELSE()
        SET(CMAKE_INSTALL_NAME_DIR "${CMAKE_INSTALL_PREFIX}/lib"
          CACHE STRING "The location of installed shared libs.")
      ENDIF()
    ELSEIF(CMAKE_SYSTEM_NAME STREQUAL "Linux")
       # use, i.e. don't skip the full RPATH for the build tree
       SET(CMAKE_SKIP_BUILD_RPATH  FALSE)

       # when building, don't use the install RPATH already
       # (but later on when installing)
       SET(CMAKE_BUILD_WITH_INSTALL_RPATH FALSE)

       # the RPATH to be used when installing
       SET(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_RPATH}:\$ORIGIN/../lib")

       # don't add the automatically determined parts of the RPATH
       # which point to directories outside the build tree to the install RPATH
       SET(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)
    ENDIF()
  ENDIF()

  # Provide for switch to static build
  #IF(WIN32 AND ${PROJECT_NAME}_ENABLE_STATIC_BUILD)
  #  INCLUDE(cmake/ScaleEnableWindowsStaticBuild.cmake)
  #ENDIF()

ENDMACRO()
