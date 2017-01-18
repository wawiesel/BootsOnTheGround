SET(tribits_name GFlags)
SET(headers
    gflags/gflags.h
)
SET(libs
    gflags
)
SET(hunter_name gflags)
SET(hunter_args )

BOTG_HuntTPL(
    "${tribits_name}"
    "${headers}"
    "${libs}"
    "${hunter_name}"
    "${hunter_args}"
)
