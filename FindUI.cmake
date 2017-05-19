# - Find UI
# Find the native UI headers and libraries.
#
#  UI_INCLUDE_DIRS - Where to find UI.h, etc.
#  UI_LIBRARIES    - List of libraries when using UI.
#  UI_FOUND        - True if UI found.
#
# If the COMPONENTS feature of UI is not set then it is assumed that
# the caller does not intend to use any of the supported components in the
# library/executable code (i.e does not intend to explicitly or implicitly include any headers
# or link against those libraries.)
# The allowed values for the COMPONENTS feature of UI are considered optional components:
# SameComponentsAsInstalledLibrary - Will require all enabled features of the installed
#   library to be found. Enabled features can be found by searching for HAVE_<Feature> in the
#   installed header. This flag will be used as COMPONENTS to all H3D libraries that this library
#   depend on.
include( H3DUtilityFunctions )
if( MSVC )
  getMSVCPostFix( msvc_postfix )
  set( ui_name "UI${msvc_postfix}" )
elseif( UNIX )
  set( ui_name h3dui )
else()
  set( ui_name UI )
endif()

handleRenamingVariablesBackwardCompatibility( NEW_VARIABLE_NAMES UI_LIBRARY_DEBUG
                                              OLD_VARIABLE_NAMES UI_DEBUG_LIBRARY
                                              DOC_STRINGS "Path to ${ui_name}_d library." )

include( H3DCommonFindModuleFunctions )
getSearchPathsH3DLibs( module_include_search_paths module_lib_search_paths ${CMAKE_CURRENT_LIST_DIR} UI )

# Look for the header file.
find_path( UI_INCLUDE_DIR NAMES H3D/UI/UI.h
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

if( UI_INCLUDE_DIR )
  handleComponentsForLib( UI
                          MODULE_HEADER_DIRS ${UI_INCLUDE_DIR}
                          MODULE_HEADER_SUFFIX /H3D/UI/UI.h
                          DESIRED ${UI_FIND_COMPONENTS}
                          REQUIRED H3DAPI
                          OUTPUT found_vars component_libraries component_include_dirs
                          H3D_MODULES H3DAPI )
endif()

include( SelectLibraryConfigurations )
select_library_configurations( UI )

include( FindPackageHandleStandardArgs )
# handle the QUIETLY and REQUIRED arguments and set UI_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args( UI DEFAULT_MSG
                                   UI_INCLUDE_DIR UI_LIBRARY ${found_vars} )

set( UI_LIBRARIES ${UI_LIBRARY} ${component_libraries} )
set( UI_INCLUDE_DIRS ${UI_INCLUDE_DIR} ${component_include_dirs} )
list( REMOVE_DUPLICATES UI_INCLUDE_DIRS )

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
