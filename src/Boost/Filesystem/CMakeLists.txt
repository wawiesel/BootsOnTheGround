TRIBITS_SUBPACKAGE(_BoostFilesystem)
BOTG_AddCompilerFlags( CXX ANY ANY
    "-std=c++11"
    "-Wl,--no-as-needed -ldl"
)
TRIBITS_ADD_TEST_DIRECTORIES(test)
TRIBITS_SUBPACKAGE_POSTPROCESS()
