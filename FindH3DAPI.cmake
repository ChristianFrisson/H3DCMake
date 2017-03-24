# - Find H3DAPI
# Find the native H3DAPI headers and libraries.
#
#  H3DAPI_INCLUDE_DIRS - Where to find H3DAPI.h, etc.
#  H3DAPI_LIBRARIES    - List of libraries when using H3DAPI.
#  H3DAPI_FOUND        - True if H3DAPI found.

include( H3DCommonFunctions )
if( MSVC )
  getMSVCPostFix( msvc_postfix )
  set( h3dapi_name "H3DAPI${msvc_postfix}" )
else()
  set( h3dapi_name h3dapi )
endif()

include( H3DExternalSearchPath )
handleRenamingVariablesBackwardCompatibility( NEW_VARIABLE_NAMES H3DAPI_LIBRARY_DEBUG
                                              OLD_VARIABLE_NAMES H3DAPI_DEBUG_LIBRARY
                                              DOC_STRINGS "Path to ${h3dapi_name}_d library." )

getSearchPathsH3DLibs( module_include_search_paths module_lib_search_paths ${CMAKE_CURRENT_LIST_DIR} H3DAPI )

# Look for the header file.
find_path( H3DAPI_INCLUDE_DIR NAMES H3D/H3DApi.h H3D/H3DApi.cmake
                              PATHS ${module_include_search_paths}
                              DOC "Path in which the file H3D/H3DAPI.h is located." )
mark_as_advanced( H3DAPI_INCLUDE_DIR )

# Look for the library.
find_library( H3DAPI_LIBRARY_RELEASE NAMES ${h3dapi_name}
                                     PATHS ${module_lib_search_paths}
                                     DOC "Path to ${h3dapi_name} library." )

find_library( H3DAPI_LIBRARY_DEBUG NAMES ${h3dapi_name}_d
                                   PATHS ${module_lib_search_paths}
                                   DOC "Path to ${h3dapi_name}_d library." )
mark_as_advanced( H3DAPI_LIBRARY_RELEASE H3DAPI_LIBRARY_DEBUG )

# OpenGL is required for using the H3DAPI library.
find_package( OpenGL )

# Glew is required for using the H3DAPI library
# On windows this will also find opengl header includes.
find_package( GLEW )

include( SelectLibraryConfigurations )
select_library_configurations( H3DAPI )

include( FindPackageHandleStandardArgs )
# handle the QUIETLY and REQUIRED arguments and set H3DAPI_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args( H3DAPI DEFAULT_MSG
                                   H3DAPI_INCLUDE_DIR H3DAPI_LIBRARY OPENGL_FOUND GLEW_FOUND )

set( H3DAPI_LIBRARIES ${H3DAPI_LIBRARY} ${OPENGL_LIBRARIES} ${GLEW_LIBRARIES} )
set( H3DAPI_INCLUDE_DIRS ${H3DAPI_INCLUDE_DIR} ${OPENGL_INCLUDE_DIR} ${GLEW_INCLUDE_DIRS} )

# Backwards compatibility values set here.
set( H3DAPI_INCLUDE_DIR ${H3DAPI_INCLUDE_DIRS} )

# Additional message on MSVC
if( H3DAPI_FOUND AND MSVC )
  if( NOT H3DAPI_LIBRARY_RELEASE )
    message( WARNING "H3DAPI release library not found. Release build might not work properly. To get rid of this warning set H3DAPI_LIBRARY_RELEASE." )
  endif()
  if( NOT H3DAPI_LIBRARY_DEBUG )
    message( WARNING "H3DAPI debug library not found. Debug build might not work properly. To get rid of this warning set H3DAPI_LIBRARY_DEBUG." )
  endif()
endif()