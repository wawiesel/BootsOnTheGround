SET(tribits_name CBLAS)

SET(headers
    cblas.h
)
SET(libs
)

#Fix-up for Darwin.
IF( BOTG_SYSTEM MATCHES "Darwin" )
    SET(path "/System/Library/Frameworks/Accelerate.framework/Versions/A/Frameworks/vecLib.framework/Versions/A/Headers")
    GLOBAL_SET( TPL_CBLAS_INCLUDE_DIRS "${TPL_CBLAS_INCLUDE_DIRS};${path}")
    MESSAGE( STATUS "[BootsOnTheGround] Darwin HOTFIX: appending path='${path}' to TPL_CBLAS_INCLUDE_DIRS" )
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
