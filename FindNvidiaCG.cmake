# - Find the NVIDIA CG Toolkit
#
#  NvidiaCG_INCLUDE_DIRS - Where to find cg.h, etc.
#  NvidiaCG_LIBRARIES    - List of libraries when using NVIDIA CG Toolkit.
#  NvidiaCG_FOUND        - True if the NVIDIA CG Toolkit is found.

include( H3DUtilityFunctions )
handleRenamingVariablesBackwardCompatibility( NEW_VARIABLE_NAMES NvidiaCG_INCLUDE_DIR NvidiaCG_LIBRARY NvidiaCG_cgGL_LIBRARY
                                              OLD_VARIABLE_NAMES NVIDIACG_INCLUDE_DIR NVIDIACG_LIBRARY NVIDIACG_CGGL_LIBRARY
                                              DOC_STRINGS "Path in which the file cg.h and cgGL.h are located."
                                                          "Path to cg library."
                                                          "Path to cgGL library." )

include( H3DCommonFindModuleFunctions )
get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )
getExternalSearchPathsH3D( module_include_search_paths module_lib_search_paths ${module_file_path} "Cg" "cg" )

# Look for the header file.
find_path( NvidiaCG_INCLUDE_DIR NAMES cg.h cgGL.h
           PATHS /usr/local/include
                 ${module_include_search_paths}
           DOC "Path in which the file cg.h and cgGL.h are located." )
mark_as_advanced( NvidiaCG_INCLUDE_DIR )

# Look for the library cg.
# Does this work on UNIX systems? (LINUX)
find_library( NvidiaCG_LIBRARY NAMES cg Cg
              PATHS ${module_lib_search_paths}
              DOC "Path to cg library." )
mark_as_advanced( NvidiaCG_LIBRARY )

# Look for the library cg.
# Does this work on UNIX systems? (LINUX)
find_library( NvidiaCG_cgGL_LIBRARY NAMES cgGL CgGL
              PATHS ${module_lib_search_paths}
              DOC "Path to cgGL library." )
mark_as_advanced( NvidiaCG_cgGL_LIBRARY )

include( FindPackageHandleStandardArgs )
# handle the QUIETLY and REQUIRED arguments and set NvidiaCG_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args( NvidiaCG DEFAULT_MSG
                                   NvidiaCG_LIBRARY NvidiaCG_cgGL_LIBRARY NvidiaCG_INCLUDE_DIR )

set( NvidiaCG_LIBRARIES ${NvidiaCG_LIBRARY} ${NvidiaCG_cgGL_LIBRARY} )
set( NvidiaCG_INCLUDE_DIRS ${NvidiaCG_INCLUDE_DIR} )

# Backwards compatibility values set here.
set( NVIDIACG_INCLUDE_DIR ${NvidiaCG_INCLUDE_DIRS} )
set( NVIDIACG_LIBRARIES ${NvidiaCG_LIBRARIES} )
set( NvidiaCG_FOUND ${NVIDIACG_FOUND} ) # find_package_handle_standard_args for CMake 2.8 only define the upper case variant.