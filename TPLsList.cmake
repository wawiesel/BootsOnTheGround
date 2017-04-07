INCLUDE(${BOTG_ROOT_DIR}/src/BOTG_TPLS.cmake)

SET(tpl_def )
FOREACH( tpl_loc ${BOTG_TPLS_LIST} )
    STRING(REPLACE "/" "_" tpl_name ${tpl_loc})
    LIST(APPEND tpl_def ${tpl_name} "${BOTG_ROOT_DIR}/src/${tpl_loc}/FindTPL${tpl_name}.cmake" TT )
ENDFOREACH()
TRIBITS_REPOSITORY_DEFINE_TPLS( ${tpl_def} )

