# - Find vld (visual leak detector)
# Find the visual leak detector headers and libraries.
#
#  VLD_INCLUDE_DIRS -  where to find vld.h,vld_def.h, etc.
#  VLD_LIBRARIES    - List of libraries when using vld.
#  VLD_FOUND        - True if vld found.

include( H3DCommonFindModuleFunctions )
get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )
getExternalSearchPathsH3D( module_include_search_paths module_lib_search_paths ${module_file_path} )

# Look for the header file.
find_path( VLD_INCLUDE_DIR NAMES vld/vld.h
                           PATHS ${module_include_search_paths}
                           DOC "Path in which the file vld/vld.h is located." )
mark_as_advanced( VLD_INCLUDE_DIR )

# Look for the library.
find_library( VLD_LIBRARY NAMES  vld
                          PATHS ${module_lib_search_paths}
                          DOC "Path to vld library." )
mark_as_advanced( VLD_LIBRARY )

include( FindPackageHandleStandardArgs )
# handle the QUIETLY and REQUIRED arguments and set VLD_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args( VLD DEFAULT_MSG
                                   VLD_LIBRARY VLD_INCLUDE_DIR )

set( VLD_LIBRARIES ${VLD_LIBRARY} )
set( VLD_INCLUDE_DIRS ${VLD_INCLUDE_DIR} )

option( VLD_FORCE_ENABLE "Enable Visual leak detector for all configurations. By default it is only enabled in debug." OFF )
