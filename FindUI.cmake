# - Find UI
# Find the native UI headers and libraries.
#
#  UI_INCLUDE_DIRS - Where to find UI.h, etc.
#  UI_LIBRARIES    - List of libraries when using UI.
#  UI_FOUND        - True if UI found.
include( H3DCommonFunctions )
if( MSVC )
  getMSVCPostFix( msvc_postfix )
  set( ui_name "UI${msvc_postfix}" )
elseif( UNIX )
  set( ui_name h3dui )
else()
  set( ui_name UI )
endif()


include( H3DExternalSearchPath )
handleRenamingVariablesBackwardCompatibility( NEW_VARIABLE_NAMES UI_LIBRARY_DEBUG
                                              OLD_VARIABLE_NAMES UI_DEBUG_LIBRARY
                                              DOC_STRINGS "Path to ${ui_name}_d library." )

getSearchPathsH3DLibs( module_include_search_paths module_lib_search_paths ${CMAKE_CURRENT_LIST_DIR} UI )

# Look for the header file.
find_path( UI_INCLUDE_DIR NAMES H3D/UI/UI.h H3D/UI/UI.cmake
                          PATHS ${module_include_search_paths}
                          DOC "Path in which the file UI/UI.h is located." )
mark_as_advanced( UI_INCLUDE_DIR )

find_library( UI_LIBRARY_RELEASE NAMES ${ui_name}
                                 PATHS ${module_lib_search_paths}
                                 DOC "Path to ${ui_name} library." )

find_library( UI_LIBRARY_DEBUG NAMES ${ui_name}_d
                               PATHS ${module_lib_search_paths}
                               DOC "Path to ${ui_name}_d library." )

mark_as_advanced( UI_LIBRARY_RELEASE UI_LIBRARY_DEBUG )

include( SelectLibraryConfigurations )
select_library_configurations( UI )

include( FindPackageHandleStandardArgs )
# handle the QUIETLY and REQUIRED arguments and set UI_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args( UI DEFAULT_MSG
                                   UI_INCLUDE_DIR UI_LIBRARY )

set( UI_LIBRARIES ${UI_LIBRARY} )
set( UI_INCLUDE_DIRS ${UI_INCLUDE_DIR} )

# Backwards compatibility values set here.
set( UI_INCLUDE_DIR ${UI_INCLUDE_DIRS} )

# Additional message on MSVC
if( UI_FOUND AND MSVC )
  if( NOT UI_LIBRARY_RELEASE )
    message( WARNING "UI release library not found. Release build might not work properly. To get rid of this warning set UI_LIBRARY_RELEASE." )
  endif()
  if( NOT UI_LIBRARY_DEBUG )
    message( WARNING "UI debug library not found. Debug build might not work properly. To get rid of this warning set UI_LIBRARY_DEBUG." )
  endif()
endif()
