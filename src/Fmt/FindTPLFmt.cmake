SET(tribits_name Fmt)
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

BOTG_HuntTPL(
    "${tribits_name}"
    "${headers}"
    "${libs}"
    "${hunter_name}"
    "${hunter_args}"
)
