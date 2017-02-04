#include <fmt/format.h>
#include <gtest/gtest.h>

TEST( Fmt, Format )
{
    EXPECT_EQ( "Elapsed time: 1.23 seconds",
               fmt::format( "Elapsed time: {0:.2f} seconds", 1.234 ) );
}
