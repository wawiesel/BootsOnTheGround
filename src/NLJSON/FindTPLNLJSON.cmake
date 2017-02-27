SET(tribits_name NLJSON)
SET(headers
    nlohmann/json.hpp
)
SET(libs )
SET(hunter_name nlohmann-json)
SET(hunter_args )

botgHuntTPL(
    "${tribits_name}"
    "${headers}"
    "${libs}"
    "${hunter_name}"
    "${hunter_args}"
)
