# - Find H3DPhysics
# Find the native H3DPhysics headers and libraries.
#
#  H3DPhysics_INCLUDE_DIRS - Where to find H3DPhysics.h, etc.
#  H3DPhysics_LIBRARIES    - List of libraries when using H3DPhysics.
#  H3DPhysics_FOUND        - True if H3DPhysics found.
include( H3DCommonFunctions )
if( MSVC )
  getMSVCPostFix( msvc_postfix )
  set( h3dphysics_name "H3DPhysics${msvc_postfix}" )
elseif( UNIX )
  set( h3dphysics_name h3dphysics )
else()
  set( h3dphysics_name H3DPhysics )
endif()


include( H3DExternalSearchPath )
handleRenamingVariablesBackwardCompatibility( NEW_VARIABLE_NAMES H3DPhysics_LIBRARY_DEBUG
                                              OLD_VARIABLE_NAMES H3DPhysics_DEBUG_LIBRARY
                                              DOC_STRINGS "Path to ${h3dphysics_name}_d library." )

getSearchPathsH3DLibs( module_include_search_paths module_lib_search_paths ${CMAKE_CURRENT_LIST_DIR} H3DPhysics )

# Look for the header file.
find_path( H3DPhysics_INCLUDE_DIR NAMES H3D/H3DPhysics/H3DPhysics.h H3D/H3DPhysics/H3DPhysics.cmake
                                  PATHS ${module_include_search_paths}
                                  DOC "Path in which the file H3DPhysics/H3DPhysics.h is located." )
mark_as_advanced( H3DPhysics_INCLUDE_DIR )

find_library( H3DPhysics_LIBRARY_RELEASE NAMES ${h3dphysics_name}
                                         PATHS ${module_lib_search_paths}
                                         DOC "Path to ${h3dphysics_name} library." )

find_library( H3DPhysics_LIBRARY_DEBUG NAMES ${h3dphysics_name}_d
                                       PATHS ${module_lib_search_paths}
                                       DOC "Path to ${h3dphysics_name}_d library." )

mark_as_advanced( H3DPhysics_LIBRARY_RELEASE H3DPhysics_LIBRARY_DEBUG )

include( SelectLibraryConfigurations )
select_library_configurations( H3DPhysics )

include( FindPackageHandleStandardArgs )
# handle the QUIETLY and REQUIRED arguments and set H3DPhysics_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args( H3DPhysics DEFAULT_MSG
                                   H3DPhysics_INCLUDE_DIR H3DPhysics_LIBRARY )

set( H3DPhysics_LIBRARIES ${H3DPhysics_LIBRARY} )
set( H3DPhysics_INCLUDE_DIRS ${H3DPhysics_INCLUDE_DIR} )

# Backwards compatibility values set here.
set( H3DPhysics_INCLUDE_DIR ${H3DPhysics_INCLUDE_DIRS} )

# Additional message on MSVC
if( H3DPhysics_FOUND AND MSVC )
  if( NOT H3DPhysics_LIBRARY_RELEASE )
    message( WARNING "H3DPhysics release library not found. Release build might not work properly. To get rid of this warning set H3DPhysics_LIBRARY_RELEASE." )
  endif()
  if( NOT H3DPhysics_LIBRARY_DEBUG )
    message( WARNING "H3DPhysics debug library not found. Debug build might not work properly. To get rid of this warning set H3DPhysics_LIBRARY_DEBUG." )
  endif()
endif()
