# Enable C-preprocessor
BOTG_AddCompilerFlags( Fortran "-cpp" )

# Enable long lines
BOTG_AddCompilerFlags( Fortran " -ffree-line-length-none" )

BOTG_AddCompilerFlags( Fortran "-pthread" )
