#-------------------------------------------------------------------------------
MACRO( BOTG_DefineTPLs )
    GLOBAL_SET( BOTG_TPL_LIST ${ARGV} )
    SET(tpl_def )
    FOREACH( tpl_loc ${ARGV} )
        STRING(REPLACE "/" "_" tpl_name ${tpl_loc})
        LIST(APPEND tpl_def ${tpl_name} "${BOTG_SOURCE_DIR}/src/${tpl_loc}/FindTPL${tpl_name}.cmake" TT )
    ENDFOREACH()
    TRIBITS_REPOSITORY_DEFINE_TPLS( ${tpl_def} )
ENDMACRO()
#-------------------------------------------------------------------------------

BOTG_DefineTPLs(
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


