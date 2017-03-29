SET(tribits_name GTEST)
SET(headers
    gtest/gtest.h
)
SET(libs
    gtest
    gtest_main
)
SET(hunter_name GTest)
SET(hunter_args )

botgHuntTPL(
    "${tribits_name}"
    "${headers}"
    "${libs}"
    "${hunter_name}"
    "${hunter_args}"
)
