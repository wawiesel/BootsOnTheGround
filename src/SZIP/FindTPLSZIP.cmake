SET(tribits_name SZIP)
SET(headers
    szlib.h
)
SET(libs
    szip
)
SET(hunter_name szip)
SET(hunter_args )
SET(hunter_find_package CONFIG REQUIRED)

botgHuntTPL(
    "${tribits_name}"
    "${headers}"
    "${libs}"
    "${hunter_name}"
    "${hunter_args}"
    "${hunter_find_package}"
)
