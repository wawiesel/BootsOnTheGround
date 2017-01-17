#include <gtest/gtest.h>
#include <boost/filesystem.hpp>
using namespace boost::filesystem;

TEST( BoostFilesystem, ThisDirectory )
{
    path p( "." );
    EXPECT_TRUE( exists( p ) );
    EXPECT_FALSE( is_regular_file( p ) );
    EXPECT_TRUE( is_directory( p ) );

    std::vector<std::string> v;
    for( auto&& x : directory_iterator( p ) )
        v.push_back( x.path().filename().string() );
    std::sort( v.begin(), v.end() );

    EXPECT_LT( 0, v.size() );
    for( auto&& x : v ) EXPECT_NE( "", x );
}
