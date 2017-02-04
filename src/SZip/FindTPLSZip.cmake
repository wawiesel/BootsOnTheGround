SET(tribits_name SZip)
SET(headers
    szlib.h
)
SET(libs
    szip
)
SET(hunter_name szip)
SET(hunter_args )

BOTG_HuntTPL(
    "${tribits_name}"
    "${headers}"
    "${libs}"
    "${hunter_name}"
    "${hunter_args}"
)
