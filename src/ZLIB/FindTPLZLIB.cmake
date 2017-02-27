SET(tribits_name ZLIB)
SET(headers
    zlib.h
)
SET(libs
    z
)
SET(hunter_name ZLIB)
SET(hunter_args )

botgHuntTPL(
    "${tribits_name}"
    "${headers}"
    "${libs}"
    "${hunter_name}"
    "${hunter_args}"
)
