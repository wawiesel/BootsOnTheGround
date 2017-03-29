botgAddCompilerFlags( CXX ANY "Linux"
    "-pthread"
)
TRIBITS_ADD_LIBRARY( BootsOnTheGround_CURL_TestLib
  SOURCES
    TestLib.cc
  TESTONLY
)
TRIBITS_ADD_EXECUTABLE_AND_TEST( test_cc
  SOURCES
    tstCURL.cc
  TESTONLYLIBS
    BootsOnTheGround_CURL_TestLib
)
TRIBITS_COPY_FILES_TO_BINARY_DIR( BootsOnTheGround_CURL_cacert
  SOURCE_FILES
    cacert.pem
  EXEDEPS
    test_cc
)
