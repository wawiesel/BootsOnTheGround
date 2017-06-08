SET(tribits_name LAPACK)

SET(headers
)
SET(libs
    lapack
)

IF( "${BOTG_SYSTEM}" STREQUAL "Windows" )
    SET(libs
        lapack_win32
    )
ENDIF()

SET(hunter_name "") #empty means hunter will not build
SET(hunter_args )

botgHuntTPL(
    "${tribits_name}"
    "${headers}"
    "${libs}"
    "${hunter_name}"
    "${hunter_args}"
)
