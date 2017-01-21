#include <openssl/sha.h>
#include <cstdio>
#include <cstring>
#include <string>

#include <gtest/gtest.h>

TEST( OpenSSL, Sha1 )
{
    unsigned char ibuf[] = "compute sha1";
    unsigned char obuf[20];

    SHA1( ibuf, sizeof( ibuf ) - 1, obuf );
    unsigned char obuf_ref[20] = {0xee, 0xfb, 0xec, 0x88, 0x5d, 0x10, 0x42,
                                  0xd2, 0x2e, 0xa3, 0x6f, 0xd1, 0x69, 0x0d,
                                  0x94, 0xde, 0xc9, 0x02, 0x96, 0x80};
    for( size_t i = 0; i < 20; ++i )
    {
        EXPECT_EQ( obuf_ref[i], obuf[i] );
    }
}
