#include <gtest/gtest.h>
#include <stdio.h>
#include <string.h>  // for strlen
#include "zlib.h"

// This Test was taken from
// https://gist.github.com/arq5x/5315739
// which was in turn adapted from
// http://stackoverflow.com/questions/7540259/deflate-and-inflate-zlib-h-in-c
TEST( ZLib, Basic )
{
    // a) original string len = 36
    // b) compressed (deflated) version of "a"
    // c) decompressed (inflated) version of "b"
    char a[50] = "Hello Hello Hello Hello Hello Hello!";
    char b[50];
    char c[50];

    // STEP 1: compression
    // setup "a" as the input and "b" as the compressed output
    z_stream defstream;
    defstream.zalloc = Z_NULL;
    defstream.zfree = Z_NULL;
    defstream.opaque = Z_NULL;
    defstream.avail_in =
        (uInt)strlen( a ) + 1;       // size of input, string + terminator
    defstream.next_in = (Bytef *)a;  // input char array
    defstream.avail_out = (uInt)sizeof( b );  // size of output
    defstream.next_out = (Bytef *)b;          // output char array
    deflateInit( &defstream, Z_BEST_COMPRESSION );
    deflate( &defstream, Z_FINISH );
    deflateEnd( &defstream );

    // check that size is smaller a>=b
    EXPECT_GE( strlen( a ), strlen( b ) );

    // STEP 2: decompression
    // setup "b" as the input and "c" as the compressed output
    z_stream infstream;
    infstream.zalloc = Z_NULL;
    infstream.zfree = Z_NULL;
    infstream.opaque = Z_NULL;
    infstream.avail_in =
        ( uInt )( (char *)defstream.next_out - b );  // size of input
    infstream.next_in = (Bytef *)b;                  // input char array
    infstream.avail_out = (uInt)sizeof( c );         // size of output
    infstream.next_out = (Bytef *)c;                 // output char array
    inflateInit( &infstream );
    inflate( &infstream, Z_NO_FLUSH );
    inflateEnd( &infstream );

    // check that size is larger b<=c
    EXPECT_LE( strlen( b ), strlen( c ) );

    // same as original
    EXPECT_EQ( strlen( a ), strlen( c ) );

    // make sure uncompressed is exactly equal to original.
    EXPECT_STREQ( a, c );
}
