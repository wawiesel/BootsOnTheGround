SET(tribits_name OpenSSL)
SET(headers
    openssl/ssl.h
    openssl/crypto.h
    openssl/bio.h
    openssl/evp.h
    openssl/sha.h
)
SET(libs
    ssl
    crypto
)
SET(hunter_name OpenSSL)
SET(hunter_args )

BOTG_HuntTPL(
    "${tribits_name}"
    "${headers}"
    "${libs}"
    "${hunter_name}"
    "${hunter_args}"
)
