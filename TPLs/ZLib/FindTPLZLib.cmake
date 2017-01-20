SET(tribits_name ZLib)
SET(headers
    zlib.h
)
SET(libs
    z
)
SET(hunter_name ZLIB)
SET(hunter_args )

BOTG_HuntTPL(
    "${tribits_name}"
    "${headers}"
    "${libs}"
    "${hunter_name}"
    "${hunter_args}"
)
