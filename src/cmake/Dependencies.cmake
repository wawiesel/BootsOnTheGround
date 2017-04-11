# must have read BOTG_TPLS.cmake and defined BOTG_TPLS_LIST!
ASSERT_DEFINED( BOTG_TPLS_LIST )
SET(super_package_contents)
FOREACH( tpl_loc ${BOTG_TPLS_LIST} )
    # replace something that looks like path with / to _
    STRING(REPLACE "/" "_" tpl_name ${tpl_loc})
    # append to list
    LIST(APPEND super_package_contents "_${tpl_name}" ${tpl_loc} ST OPTIONAL )
ENDFOREACH()

# Declare contents
botgSuperPackageContents(
    ${super_package_contents}
)
