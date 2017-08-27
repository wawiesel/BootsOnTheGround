SET(tribits_name NLJSON)
SET(headers
    nlohmann/json.hpp
)
SET(libs )
SET(hunter_name nlohmann_json)
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
