SET(tribits_name GTest)
SET(headers
    gtest/gtest.h
)
SET(libs
    gtest
    gtest_main
)
SET(hunter_name GTest)
SET(hunter_args )

BOTG_HuntTPL(
    "${tribits_name}"
    "${headers}"
    "${libs}"
    "${hunter_name}"
    "${hunter_args}"
)
