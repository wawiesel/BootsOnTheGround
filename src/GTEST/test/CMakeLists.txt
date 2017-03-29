botgAddCompilerFlags( CXX ANY "Linux"
    "-pthread"
)
TRIBITS_ADD_EXECUTABLE_AND_TEST( test_cc
  SOURCES
    tstGTEST.cc
)
