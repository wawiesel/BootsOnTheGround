SET(tribits_name ZLIB)
SET(headers
    zlib.h
)
SET(libs
    z
)
SET(hunter_name ZLIB)
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
