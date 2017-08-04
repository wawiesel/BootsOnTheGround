#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <cblas.h>

int main()
{

    //set up some data
    int n=300;
    float* x = malloc( n*sizeof(float) );
    float* y = malloc( n*sizeof(float) );
    for( int i=0; i<n; ++i )
    {
        x[i]=i+1;
        y[i]=(i+1)*(i+1);
    }

    //calculate y = a*x + y
    float a=7.0f;
    int incx=1;
    int incy=1;
    cblas_saxpy( n, a, x, incx, y, incy );

    //check it
    int status = 0;
    for( int i=0; i<n; ++i )
    {
        float expected = 7.0f*(i+1) + (i+1)*(i+1);
        if( fabs( y[i]/expected - 1 )>1e-4 ){
            printf("error matching element i=%d expected=%g received=%g\n",i+1,expected,y[i]);
            status=-1;
            break;
        }
    }

    //free data
    free(x);
    free(y);

    return status;

}
