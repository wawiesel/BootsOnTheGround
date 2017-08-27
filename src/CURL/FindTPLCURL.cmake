SET(tribits_name CURL)
SET(headers
    curl/curl.h
    curl/easy.h
    curl/curlbuild.h
)
SET(libs
    curl
    idn
    lber
    ldap
    dl
)
SET(hunter_name CURL)
SET(hunter_args )
SET(hunter_find_package CONFIG REQUIRED)

botgHuntTPL(
    "${tribits_name}"
    "${headers}"
    "${libs}"
    "${hunter_name}"
    "${hunter_args}"
    "${hunter_find_package}"
)
