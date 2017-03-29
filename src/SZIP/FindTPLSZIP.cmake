SET(tribits_name SZIP)
SET(headers
    szlib.h
)
SET(libs
    szip
)
SET(hunter_name szip)
SET(hunter_args )

botgHuntTPL(
    "${tribits_name}"
    "${headers}"
    "${libs}"
    "${hunter_name}"
    "${hunter_args}"
)
