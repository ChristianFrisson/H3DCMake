# - Find GeoSpatial
# Find the native GeoSpatial headers and libraries.
#
#  GeoSpatial_INCLUDE_DIRS - Where to find GeoSpatial.h, etc.
#  GeoSpatial_LIBRARIES    - List of libraries when using GeoSpatial.
#  GeoSpatial_FOUND        - True if GeoSpatial found.
include( H3DCommonFunctions )
if( MSVC )
  getMSVCPostFix( msvc_postfix )
  set( geospatial_name "GeoSpatial${msvc_postfix}" )
elseif( UNIX )
  set( geospatial_name geospatial )
else()
  set( geospatial_name GeoSpatial )
endif()


include( H3DExternalSearchPath )
handleRenamingVariablesBackwardCompatibility( NEW_VARIABLE_NAMES GeoSpatial_LIBRARY_DEBUG
                                              OLD_VARIABLE_NAMES GeoSpatial_DEBUG_LIBRARY
                                              DOC_STRINGS "Path to ${geospatial_name}_d library." )

getSearchPathsH3DLibs( module_include_search_paths module_lib_search_paths ${CMAKE_CURRENT_LIST_DIR} GeoSpatial )

# Look for the header file.
find_path( GeoSpatial_INCLUDE_DIR NAMES H3D/GeoSpatial/GeoSpatial.h H3D/GeoSpatial/GeoSpatial.cmake
                                  PATHS ${module_include_search_paths}
                                  DOC "Path in which the file GeoSpatial/GeoSpatial.h is located." )
mark_as_advanced( GeoSpatial_INCLUDE_DIR )

find_library( GeoSpatial_LIBRARY_RELEASE NAMES ${geospatial_name}
                                         PATHS ${module_lib_search_paths}
                                         DOC "Path to ${geospatial_name} library." )

find_library( GeoSpatial_LIBRARY_DEBUG NAMES ${geospatial_name}_d
                                       PATHS ${module_lib_search_paths}
                                       DOC "Path to ${geospatial_name}_d library." )

mark_as_advanced( GeoSpatial_LIBRARY_RELEASE GeoSpatial_LIBRARY_DEBUG )

include( SelectLibraryConfigurations )
select_library_configurations( GeoSpatial )

include( FindPackageHandleStandardArgs )
# handle the QUIETLY and REQUIRED arguments and set GeoSpatial_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args( GeoSpatial DEFAULT_MSG
                                   GeoSpatial_INCLUDE_DIR GeoSpatial_LIBRARY )

set( GeoSpatial_LIBRARIES ${GeoSpatial_LIBRARY} )
set( GeoSpatial_INCLUDE_DIRS ${GeoSpatial_INCLUDE_DIR} )

# Backwards compatibility values set here.
set( GeoSpatial_INCLUDE_DIR ${GeoSpatial_INCLUDE_DIRS} )

# Additional message on MSVC
if( GeoSpatial_FOUND AND MSVC )
  if( NOT GeoSpatial_LIBRARY_RELEASE )
    message( WARNING "GeoSpatial release library not found. Release build might not work properly. To get rid of this warning set GeoSpatial_LIBRARY_RELEASE." )
  endif()
  if( NOT GeoSpatial_LIBRARY_DEBUG )
    message( WARNING "GeoSpatial debug library not found. Debug build might not work properly. To get rid of this warning set GeoSpatial_LIBRARY_DEBUG." )
  endif()
endif()
