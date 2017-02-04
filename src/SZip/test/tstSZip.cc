#include <gtest/gtest.h>
#include <szlib.h>
#include "TestLib.h"

TEST( SZip, Basic )
{
    // This test case has been copied and cleaned up from
    //
    // https://github.com/erdc-cm/szip/blob/master/test/gentest.c
    //
    int blocks = 1024;
    int image_size = blocks * 4 * 32 * 2;
    char* image_in = new char[image_size];
    char* image_in2 = new char[image_size];
    char* image_out = new char[image_size];

    BOTG_SZip_TestInit();

    for( int nn_mode = 0; nn_mode < 2; nn_mode++ )
    {
        for( int msb_first = 0; msb_first < 2; msb_first++ )
        {
            for( int j = 8; j <= 32; j += 2 )
            {
                for( int n = 4; n <= 24; n++ )
                {
                    EXPECT_EQ( 1,
                               BOTG_SZip_TestRun( image_in,
                                                  image_in2,
                                                  image_out,
                                                  image_size,
                                                  nn_mode,
                                                  msb_first,
                                                  n,
                                                  j,
                                                  blocks ) );
                }
            }
        }
    }

    delete[] image_in;
    delete[] image_in2;
    delete[] image_out;
}
