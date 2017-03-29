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

botgHuntTPL(
    "${tribits_name}"
    "${headers}"
    "${libs}"
    "${hunter_name}"
    "${hunter_args}"
)
