TRIBITS_ADD_LIBRARY( BootsOnTheGround_SZip_TestLib
  SOURCES
    TestLib.c
  TESTONLY
)

TRIBITS_ADD_EXECUTABLE_AND_TEST( test_cc
  SOURCES
    tstSZip.cc
  TESTONLYLIBS
    BootsOnTheGround_SZip_TestLib
)
