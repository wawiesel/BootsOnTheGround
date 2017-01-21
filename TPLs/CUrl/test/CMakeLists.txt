TRIBITS_ADD_LIBRARY( BootsOnTheGround_CUrl_TestLib
  SOURCES
    TestLib.cc
  TESTONLY
)
TRIBITS_ADD_EXECUTABLE_AND_TEST( test_cc
  SOURCES
    tstCUrl.cc
  TESTONLYLIBS
    BootsOnTheGround_CUrl_TestLib
)
TRIBITS_COPY_FILES_TO_BINARY_DIR( BootsOnTheGround_CUrl_cacert
  SOURCE_FILES
    cacert.pem
  EXEDEPS
    test_cc
)
