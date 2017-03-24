# - Find H3DUtil
# Find the native H3DUtil headers and libraries.
#
#  H3DUtil_INCLUDE_DIRS - Where to find H3DUtil.h, etc.
#  H3DUtil_LIBRARIES    - List of libraries when using H3DUtil.
#  H3DUtil_FOUND        - True if H3DUtil found.
include( H3DCommonFunctions )
if( MSVC )
  getMSVCPostFix( msvc_postfix )
  set( h3dutil_name "H3DUtil${msvc_postfix}" )
else()
  set( h3dutil_name h3dutil )
endif()

include( H3DExternalSearchPath )
handleRenamingVariablesBackwardCompatibility( NEW_VARIABLE_NAMES H3DUtil_LIBRARY_RELEASE H3DUtil_LIBRARY_DEBUG H3DUtil_INCLUDE_DIR
                                              OLD_VARIABLE_NAMES H3DUTIL_LIBRARY H3DUTIL_DEBUG_LIBRARY
                                              DOC_STRINGS "Path to ${h3dutil_name} library."
                                                          "Path to ${h3dutil_name}_d library."
                                                          "Path in which the file H3DUtil/H3DUtil.h is located." )

getSearchPathsH3DLibs( module_include_search_paths module_lib_search_paths ${CMAKE_CURRENT_LIST_DIR} H3DUtil )

# Look for the header file.
find_path( H3DUtil_INCLUDE_DIR NAMES H3DUtil/H3DUtil.h H3DUtil/H3DUtil.cmake
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

include( SelectLibraryConfigurations )
select_library_configurations( H3DUtil )

# PTHREAD is required for using the H3DUtil library.
find_package( PTHREAD )

include( FindPackageHandleStandardArgs )
# handle the QUIETLY and REQUIRED arguments and set H3DUtil_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args( H3DUtil DEFAULT_MSG
                                   H3DUtil_INCLUDE_DIR H3DUtil_LIBRARY PTHREAD_FOUND )

set( H3DUtil_LIBRARIES ${H3DUtil_LIBRARY} ${PTHREAD_LIBRARIES} )
set( H3DUtil_INCLUDE_DIRS ${H3DUtil_INCLUDE_DIR}  ${PTHREAD_INCLUDE_DIRS} )

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
