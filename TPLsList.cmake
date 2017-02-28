#-------------------------------------------------------------------------------
MACRO( botgDefineTPLs )
    SET(tpl_def )
    FOREACH( tpl_loc ${ARGV} )
        STRING(REPLACE "/" "_" tpl_name ${tpl_loc})
        LIST(APPEND tpl_def ${tpl_name} "${BOTG_ROOT_DIR}/src/${tpl_loc}/FindTPL${tpl_name}.cmake" TT )
    ENDFOREACH()
    TRIBITS_REPOSITORY_DEFINE_TPLS( ${tpl_def} )
ENDMACRO()
#-------------------------------------------------------------------------------

botgDefineTPLs(
    GTEST
    BOOST/FILESYSTEM
    SPDLOG
    GFLAGS
    FMT
    NLJSON
    OPENSSL
    ZLIB
    SZIP
    HDF5
    CURL
)

