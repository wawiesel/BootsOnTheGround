#include <stdio.h>
#include <string.h>
#include <time.h>

#include "TestLib.h"

// This test case has been copied and cleaned up from
//
// https://github.com/erdc-cm/szip/blob/master/test/gentest.c
//

#define MULT 69069L

#define MASK32 0xFFFFFFFFUL

static unsigned long mcgn, srgn;

void BOTG_SZip_TestInit()
{
    long i2 = time( 0 );
    long i1 = -i2;
    mcgn = ( i1 == 0 ) ? 0 : i1 | 1;
    mcgn &= MASK32;

    srgn = ( i2 == 0 ) ? 0 : ( i2 & 0x7ff ) | 1;
    srgn &= MASK32;
}

long iuni()
{
    unsigned long r0, r1;

    r0 = ( srgn >> 15 );
    r1 = srgn ^ r0;
    r0 = ( r1 << 17 );
    r0 &= MASK32;
    srgn = r0 ^ r1;
    mcgn = MULT * mcgn;
    mcgn &= MASK32;
    r1 = mcgn ^ srgn;
    return ( ( r1 >> 1 ) );
}

long ivni()
{
    unsigned long r0, r1;

    r0 = ( srgn >> 15 );
    r1 = srgn ^ r0;
    r0 = ( r1 << 17 );
    r0 &= MASK32;
    srgn = r0 ^ r1;
    mcgn = MULT * mcgn;
    mcgn &= MASK32;
    r1 = mcgn ^ srgn;
    return ( r1 );
}

double uni()
{
    unsigned long r0, r1;

    r0 = ( srgn >> 15 );
    r1 = srgn ^ r0;
    r0 = ( r1 << 17 );
    r0 &= 0xFFFFFFFFUL;
    srgn = r0 ^ r1;
    mcgn = MULT * mcgn;
    mcgn &= 0xFFFFFFFFUL;
    r1 = mcgn ^ srgn;
    return ( (double)( r1 >> 1 ) / 2147483648. );
}

double vni()
{
    unsigned long r0, r1;

    r0 = ( srgn >> 15 );
    r1 = srgn ^ r0;
    r0 = ( r1 << 17 );
    r0 &= 0xFFFFFFFFUL;
    srgn = r0 ^ r1;
    mcgn = MULT * mcgn;
    mcgn &= 0xFFFFFFFFUL;
    r1 = mcgn ^ srgn;
    return ( (double)( r1 ) / 2147483648. );
}

void output_pixel( char* bp,
                   int msb_first,
                   unsigned bits_per_pixel,
                   unsigned pixel )
{
    if( msb_first )
    {
        if( bits_per_pixel <= 8 )
            *bp++ = pixel & 0xff;
        else if( bits_per_pixel <= 16 )
        {
            *bp++ = ( pixel >> 8 ) & 0xff;
            *bp++ = pixel & 0xff;
        }
        else
        {
            *bp++ = 0;
            *bp++ = ( pixel >> 16 ) & 0xff;
            *bp++ = ( pixel >> 8 ) & 0xff;
            *bp++ = pixel & 0xff;
        }
    }
    else
    {
        if( bits_per_pixel <= 8 )
            *bp++ = pixel & 0xff;
        else if( bits_per_pixel <= 16 )
        {
            *bp++ = pixel & 0xff;
            *bp++ = ( pixel >> 8 ) & 0xff;
        }
        else
        {
            *bp++ = pixel & 0xff;
            *bp++ = ( pixel >> 8 ) & 0xff;
            *bp++ = ( pixel >> 16 ) & 0xff;
            *bp++ = 0;
        }
    }
}
void unmap_nn( unsigned xmax, unsigned* sigma, long pixels, unsigned* out )
{
    int sig1;
    int sig2;
    int x;
    unsigned* end;
    unsigned* s;

    end = sigma + pixels;
    s = sigma;

    x = *s++;
    *out++ = x;

    sig1 = *s++;
    if( sig1 >= ( x << 1 ) )
        x = sig1;
    else if( sig1 > ( xmax - x ) << 1 )
        x = xmax - sig1;
    else if( sig1 & 1 )
        x = x - ( ( sig1 + 1 ) >> 1 );
    else
        x = x + ( sig1 >> 1 );

    *out++ = x;

    while( s < end )
    {
        sig1 = *s++;
        sig2 = *s++;
        if( sig1 >= ( x << 1 ) )
            x = sig1;
        else if( sig1 > ( xmax - x ) << 1 )
            x = xmax - sig1;
        else if( sig1 & 1 )
            x = x - ( ( sig1 + 1 ) >> 1 );
        else
            x = x + ( sig1 >> 1 );

        *out++ = x;

        if( sig2 >= ( x << 1 ) )
            x = sig2;
        else if( sig2 > ( xmax - x ) << 1 )
            x = xmax - sig2;
        else if( sig2 & 1 )
            x = x - ( ( sig2 + 1 ) >> 1 );
        else
            x = x + ( sig2 >> 1 );

        *out++ = x;
    }
}

void genblock( unsigned* sp,
               unsigned xmax,
               char* bp,
               char* image_in,
               int msb_first,
               int sum,
               int j,
               int n )
{
    double average;
    int k;
    int i;
    long x;
    double v;
    average = sum / (double)j;
    average *= 2;
    for( k = 0; k < j; k++ )
    {
        v = 0;
        for( i = 0; i < 6; i++ ) v += uni();
        v /= 6.0;
        x = ( v * average ) + 0.5;
        x &= xmax;
        if( x + ( j - k - 1 ) * xmax < sum ) x = sum - ( j - k - 1 ) * xmax;
        if( x > sum ) x = sum;
        *sp++ = x;
        sum -= x;
    }
}

void genimage(
    char* image_in, int nn_mode, int msb_first, int n, int j, int blocks )
{
    int i;
    int k;
    int sum;
    int sum_array[32];
    unsigned sigma[1024];
    unsigned sigma_out[1024];
    unsigned* send;
    char* bp;
    unsigned* sp;
    bp = image_in;

    unsigned xmax = ( 1 << n ) - 1;

    sum_array[0] = 0;
    sum_array[1] = 3;
    sum_array[2] = j / 2 * 3;
    for( i = 3; i < 26; i++ ) sum_array[i] = sum_array[i - 1] * 2 + j / 2;

    sp = sigma;
    send = sigma + j * 16;
    for( k = 0; k < blocks; k++ )
    {
        /*** make sum_array[i-1] <= sum <= sum_array[i] ***/
        i = uni() * ( n + 2 );
        if( i == 0 )
            sum = 0;
        else
            sum = ( sum_array[i] - sum_array[i - 1] ) * uni() + 1;

        if( sum > j * xmax )
        {
            k--;
            continue;
        }
        genblock( sp, xmax, bp, image_in, msb_first, sum, j, n );
        if( sp == send )
        {
            if( nn_mode )
            {
                sigma[0] = uni() * ( xmax + 1 );
                unmap_nn( xmax, sigma, send - sigma, sigma_out );
                sp = sigma_out;
                send = sigma_out + j * 16;
            }
            else
                sp = sigma;

            for( ; sp < send; sp++ ) output_pixel( bp, msb_first, n, *sp );

            sp = sigma;
            send = sigma + j * 16;
        }
    }
}

int BOTG_SZip_TestRun( char* image_in,
                       char* image_in2,
                       char* image_out,
                       int max_image_size,
                       int nn_mode,
                       int msb_first,
                       int n,
                       int j,
                       int blocks )
{
    SZ_com_t params;
    int count;
    int i;
    int rv;

    genimage( image_in, nn_mode, msb_first, n, j, blocks );

    int image_size = blocks * j;
    if( n > 16 )
        image_size *= 4;
    else if( n > 8 )
        image_size *= 2;

    params.options_mask = SZ_RAW_OPTION_MASK | SZ_ALLOW_K13_OPTION_MASK;
    if( msb_first )
        params.options_mask |= SZ_MSB_OPTION_MASK;
    else
        params.options_mask |= SZ_LSB_OPTION_MASK;

    params.bits_per_pixel = n;
    params.pixels_per_block = j;
    params.pixels_per_scanline = 256;

    params.options_mask |= ( nn_mode ? SZ_NN_OPTION_MASK : SZ_EC_OPTION_MASK );

    size_t size = max_image_size;
    rv = SZ_BufftoBuffCompress(
        image_out, &size, image_in, image_size, &params );
    if( rv != SZ_OK ) return 0;

    size_t size2 = max_image_size;
    rv = SZ_BufftoBuffDecompress( image_in2, &size2, image_out, size, &params );
    if( rv != SZ_OK ) return 0;

    rv = memcmp( image_in, image_in2, image_size );
    if( rv ) return 0;

    return 1;
}
