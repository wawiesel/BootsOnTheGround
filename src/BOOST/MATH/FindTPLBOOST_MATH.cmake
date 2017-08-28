SET(tribits_name BOOST_MATH)
SET(headers
	boost/math/common_factor.hpp
	boost/math/complex.hpp
	boost/math/distributions.hpp
	boost/math/octonion.hpp
	boost/math/quaternion.hpp
	boost/math/special_functions.hpp
)
SET(libs
)
SET(hunter_name Boost)
SET(hunter_args
)
SET(hunter_find_package REQUIRED)

botgHuntTPL(
    "${tribits_name}"
    "${headers}"
    "${libs}"
    "${hunter_name}"
    "${hunter_args}"
    "${hunter_find_package}"
)

