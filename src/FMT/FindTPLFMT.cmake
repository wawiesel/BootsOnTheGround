SET(tribits_name FMT)
SET(headers
    fmt/format.h
    fmt/ostream.h
    fmt/posix.h
    fmt/time.h
)
SET(libs
    fmt
)
SET(hunter_name fmt)
SET(hunter_args )
SET(hunter_find_package REQUIRED)

botgHuntTPL(
    "${tribits_name}"
    "${headers}"
    "${libs}"
    "${hunter_name}"
    "${hunter_args}"
    "${hunter_find_package}"
)
