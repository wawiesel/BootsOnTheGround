SET(tribits_name BOOST_FILESYSTEM)
SET(headers
    boost/filesystem.hpp
)
SET(libs
    boost_filesystem-mt
    boost_system-mt
)
SET(hunter_name Boost)
SET(hunter_args
  COMPONENTS
    system filesystem
)

BOTG_HuntTPL(
    "${tribits_name}"
    "${headers}"
    "${libs}"
    "${hunter_name}"
    "${hunter_args}"
)
