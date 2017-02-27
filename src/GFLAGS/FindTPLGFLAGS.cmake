SET(tribits_name GFLAGS)
SET(headers
    gflags/gflags.h
)
SET(libs
    gflags
)
SET(hunter_name gflags)
SET(hunter_args )

botgHuntTPL(
    "${tribits_name}"
    "${headers}"
    "${libs}"
    "${hunter_name}"
    "${hunter_args}"
)
