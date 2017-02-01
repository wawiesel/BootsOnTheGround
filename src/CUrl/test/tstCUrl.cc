#include <gtest/gtest.h>
#include <iostream>
#include <string>
#include "TestLib.hh"

TEST( CUrl, Http )
{
    // check that we can get content from http://
    HTTPDownloader downloader;
    std::string content = downloader.download( "http://stackoverflow.com" );
    EXPECT_NE( "", content ) << content << std::endl;
}

TEST( CUrl, Https )
{
    // check that we can get content from https://
    HTTPDownloader downloader;
    std::string content = downloader.download( "https://stackoverflow.com" );
    EXPECT_NE( "", content ) << content << std::endl;
}
