#ifndef BOTG_SZip_TestLib_H
#define BOTG_SZip_TestLib_H

#include <szlib.h>

#ifdef __cplusplus
extern "C" {
#endif

int BOTG_SZip_TestRun( char* image_in,
                       char* image_in2,
                       char* image_out,
                       int image_size,
                       int nn_mode,
                       int msb_first,
                       int n,
                       int j,
                       int blocks );
void BOTG_SZip_TestInit();

#ifdef __cplusplus
}
#endif

#endif
