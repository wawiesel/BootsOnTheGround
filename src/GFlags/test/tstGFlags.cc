// from https://github.com/gflags/example/blob/master/foo/main.cc
#include <gtest/gtest.h>
#include <iostream>
#include "gflags/gflags.h"

DEFINE_bool( verbose, false, "Display program name before message" );
DEFINE_string( message, "Hello world!", "Message to print" );

static bool IsNonEmptyMessage( const char *flagname, const std::string &value )
{
    return value[0] != '\0';
}
DEFINE_validator( message, &IsNonEmptyMessage );

TEST( GFlags, Basic )
{
    gflags::SetUsageMessage( "some usage message" );
    gflags::SetVersionString( "1.0.0" );
    gflags::ReadFlagsFromString( "--verbose",
                                 gflags::GetArgv0(),
                                 // errors are fatal
                                 true );
    EXPECT_TRUE( FLAGS_verbose );
    EXPECT_EQ( "Hello world!", FLAGS_message );
    gflags::ShutDownCommandLineFlags();
}
