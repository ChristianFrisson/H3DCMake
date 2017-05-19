# - Find H3DUtil
# Find the native H3DUtil headers and libraries.
#
# H3DUtil_INCLUDE_DIRS - Where to find H3DUtil.h, etc.
# H3DUtil_LIBRARIES    - List of libraries when using H3DUtil.
# H3DUtil_FOUND        - True if H3DUtil found.
#
# If the COMPONENTS feature of H3DUtil is not set then it is assumed that
# the caller does not intend to use any of the supported components in the
# library/executable code (i.e does not intend to explicitly or implicitly include any headers
# or link against those libraries.)
# The allowed values for the COMPONENTS feature of H3DUtil are considered optional components:
# SameComponentsAsInstalledLibrary - Will require all enabled features of the installed
#   library to be found. Enabled features can be found by searching for HAVE_<Feature> in the
#   installed header. This flag will be used as COMPONENTS to all H3D libraries that this library
#   depend on.
# SofaHelper - Used to enable profiling.
# VLD - Used to enable memory leak profiling.
# ZLIB - Used to compress/uncompress files.
# FreeImage - Used to add support for reading/writing to a number of image file formats.
# Teem - Used to add support for the nrrd file format.
# DCMTK - Used to add support for DICOM file format.
# NvidiaToolsExt - Used for debugging with Nvidia Tools Extension Library.
# OpenEXR - Used to add support for exr file format.
include( H3DUtilityFunctions )
if( MSVC )
  getMSVCPostFix( msvc_postfix )
  set( h3dutil_name "H3DUtil${msvc_postfix}" )
else()
  set( h3dutil_name h3dutil )
endif()

handleRenamingVariablesBackwardCompatibility( NEW_VARIABLE_NAMES H3DUtil_LIBRARY_RELEASE H3DUtil_LIBRARY_DEBUG
                                              OLD_VARIABLE_NAMES H3DUTIL_LIBRARY H3DUTIL_DEBUG_LIBRARY
                                              DOC_STRINGS "Path to ${h3dutil_name} library."
                                                          "Path to ${h3dutil_name}_d library." )

include( H3DCommonFindModuleFunctions )
getSearchPathsH3DLibs( module_include_search_paths module_lib_search_paths ${CMAKE_CURRENT_LIST_DIR} H3DUtil )

# Look for the header file.
find_path( H3DUtil_INCLUDE_DIR NAMES H3DUtil/H3DUtil.h
                               PATHS ${module_include_search_paths}
                               DOC "Path in which the file H3DUtil/H3DUtil.h is located." )
mark_as_advanced( H3DUtil_INCLUDE_DIR )

find_library( H3DUtil_LIBRARY_RELEASE NAMES ${h3dutil_name}
                              PATHS ${module_lib_search_paths}
                              DOC "Path to ${h3dutil_name} library." )

find_library( H3DUtil_LIBRARY_DEBUG NAMES ${h3dutil_name}_d
                                    PATHS ${module_lib_search_paths}
                                    DOC "Path to ${h3dutil_name}_d library." )

mark_as_advanced( H3DUtil_LIBRARY_RELEASE H3DUtil_LIBRARY_DEBUG )

if( H3DUtil_INCLUDE_DIR )
  handleComponentsForLib( H3DUtil
                          MODULE_HEADER ${H3DUtil_INCLUDE_DIR}/H3DUtil/H3DUtil.h
                          DESIRED ${H3DUtil_FIND_COMPONENTS}
                          REQUIRED PTHREAD
                          OPTIONAL         SofaHelper    VLD         ZLIB      FreeImage      Teem      DCMTK      NvidiaToolsExt OpenEXR
                          OPTIONAL_DEFINES HAVE_PROFILER HAVE_LIBVLD HAVE_ZLIB HAVE_FREEIMAGE HAVE_TEEM HAVE_DCMTK HAVE_NVIDIATX  HAVE_OPENEXR
                          OUTPUT found_vars component_libraries component_include_dirs )
endif()

include( SelectLibraryConfigurations )
select_library_configurations( H3DUtil )

include( FindPackageHandleStandardArgs )
# handle the QUIETLY and REQUIRED arguments and set H3DUtil_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args( H3DUtil DEFAULT_MSG
                                   H3DUtil_INCLUDE_DIR H3DUtil_LIBRARY ${found_vars} )

set( H3DUtil_LIBRARIES ${H3DUtil_LIBRARY} ${component_libraries} )
set( H3DUtil_INCLUDE_DIRS ${H3DUtil_INCLUDE_DIR} ${component_include_dirs} )
list( REMOVE_DUPLICATES H3DUtil_INCLUDE_DIRS )

# Backwards compatibility values set here.
set( H3DUTIL_INCLUDE_DIR ${H3DUtil_INCLUDE_DIRS} )
set( H3DUTIL_LIBRARIES ${H3DUtil_LIBRARIES} )
set( H3DUtil_FOUND ${H3DUTIL_FOUND} ) # find_package_handle_standard_args for CMake 2.8 only define the upper case variant.

# Additional message on MSVC
if( H3DUtil_FOUND AND MSVC )
  if( NOT H3DUtil_LIBRARY_RELEASE )
    message( WARNING "H3DUtil release library not found. Release build might not work properly. To get rid of this warning set H3DUtil_LIBRARY_RELEASE." )
  endif()
  if( NOT H3DUtil_LIBRARY_DEBUG )
    message( WARNING "H3DUtil debug library not found. Debug build might not work properly. To get rid of this warning set H3DUtil_LIBRARY_DEBUG." )
  endif()
endif()
