# - Find LibOVR
# Find the native LibOVR headers and libraries.
#
#  LibOVR_INCLUDE_DIRS - Where to find OVR_CAPI_GL.h, etc.
#  LibOVR_LIBRARIES    - List of libraries when using LibOVR.
#  LibOVR_FOUND        - True if LibOVR found.

include( H3DUtilityFunctions )
handleRenamingVariablesBackwardCompatibility( NEW_VARIABLE_NAMES LibOVR_INCLUDE_DIR LibOVR_LIBRARY
                                              DOC_STRINGS "Path in which the file OVR_CAPI_GL.h is located. Needed to support the OCULUS_RIFT stereo mode."
                                                          "Path to LibOVR library. Needed to support the OCULUS_RIFT stereo mode." )

include( H3DCommonFindModuleFunctions )
if( MSVC )
  set( check_if_h3d_external_matches_vs_version ON )
endif()
get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )
getExternalSearchPathsH3D( module_include_search_paths module_lib_search_paths ${module_file_path} "LibOVR" "static" )

# Look for the header file.
find_path( LibOVR_INCLUDE_DIR NAMES OVR_CAPI_GL.h
                              PATHS ${module_include_search_paths}
                              DOC "Path in which the file OVR_CAPI_GL.h is located. Needed to support the OCULUS_RIFT stereo mode." )

mark_as_advanced( LibOVR_INCLUDE_DIR )

# Look for the library.
find_library( LibOVR_LIBRARY NAMES libovr
                             PATHS ${module_lib_search_paths}
                             DOC "Path to LibOVR library. Needed to support the OCULUS_RIFT stereo mode." )
mark_as_advanced( LibOVR_LIBRARY )

include( FindPackageHandleStandardArgs )
# handle the QUIETLY and REQUIRED arguments and set LibOVR_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args( LibOVR DEFAULT_MSG
                                   LibOVR_LIBRARY LibOVR_INCLUDE_DIR )

set( LibOVR_LIBRARIES ${LibOVR_LIBRARY} )
set( LibOVR_INCLUDE_DIRS ${LibOVR_INCLUDE_DIR} )

# Backwards compatibility values set here.
set( LIBOVR_INCLUDE_DIR ${LibOVR_INCLUDE_DIRS} )
set( LIBOVR_LIBRARIES ${LibOVR_LIBRARIES} )
set( LibOVR_FOUND ${LIBOVR_FOUND} ) # find_package_handle_standard_args for CMake 2.8 only define the upper case variant.