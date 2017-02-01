SET(tribits_name NLJson)
SET(headers
    nlohmann/json.hpp
)
SET(libs )
SET(hunter_name nlohmann-json)
SET(hunter_args )

BOTG_HuntTPL(
    "${tribits_name}"
    "${headers}"
    "${libs}"
    "${hunter_name}"
    "${hunter_args}"
)
