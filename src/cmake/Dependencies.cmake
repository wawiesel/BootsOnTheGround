#-------------------------------------------------------------------------------
MACRO( BOTG_DefineTPLSubPackages )

    # clear TriBITS variables
    SET(SUBPACKAGES_DIRS_CLASSIFICATIONS_OPTREQS )
    SET(LIB_REQUIRED_DEP_PACKAGES)
    SET(LIB_OPTIONAL_DEP_PACKAGES)
    SET(TEST_REQUIRED_DEP_PACKAGES)
    SET(TEST_OPTIONAL_DEP_PACKAGES)
    SET(LIB_REQUIRED_DEP_TPLS)
    SET(LIB_OPTIONAL_DEP_TPLS)
    SET(TEST_REQUIRED_DEP_TPLS)
    SET(TEST_OPTIONAL_DEP_TPLS)

    # setup up the subpackages list
    FOREACH( tpl_loc ${BOTG_TPL_LIST} )
        STRING(REPLACE "/" "" tpl_name ${tpl_loc})
        LIST(APPEND SUBPACKAGES_DIRS_CLASSIFICATIONS_OPTREQS
             "_${tpl_name}" ${tpl_loc} ST OPTIONAL )
    ENDFOREACH()

ENDMACRO()
#-------------------------------------------------------------------------------

BOTG_DefineTPLSubPackages()
