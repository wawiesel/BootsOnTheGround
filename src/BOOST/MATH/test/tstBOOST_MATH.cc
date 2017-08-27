#include <gtest/gtest.h>
#include <boost/math/distributions.hpp>
using namespace boost::math;

TEST( BoostMath, Stats )
{
	// get a normal distribution with mean and standard deviation
	double mean = 0.0;
	double stdev = 1.0;
	normal dist( mean, stdev );

	// 95% of distribution is below q:
	double q = quantile(dist, 0.95);
	EXPECT_FLOAT_EQ( 1.6448536, q );
}
