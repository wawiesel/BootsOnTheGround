SET(tribits_name SPDLOG)
SET(headers
    spdlog/async_logger.h
    spdlog/common.h
    spdlog/formatter.h
    spdlog/logger.h
    spdlog/spdlog.h
    spdlog/tweakme.h
)
SET(libs )
SET(hunter_name spdlog)
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
