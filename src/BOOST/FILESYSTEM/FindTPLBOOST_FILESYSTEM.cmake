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
  system filesystem
)
SET(hunter_find_package CONFIG REQUIRED)

botgHuntTPL(
    "${tribits_name}"
    "${headers}"
    "${libs}"
    "${hunter_name}"
    "${hunter_args}"
    "${hunter_find_package}"
)
