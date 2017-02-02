SET(tribits_name HDF5)
SET(headers
    hdf5.h
    H5Cpp.h
)

SET(libs
    hdf5_hl_cpp
    hdf5_cpp
    hdf5_hl
    hdf5
)
SET(hunter_name hdf5)
SET(hunter_args )

BOTG_HuntTPL(
    "${tribits_name}"
    "${headers}"
    "${libs}"
    "${hunter_name}"
    "${hunter_args}"
)
