# - Find FTGL
# Find the native FTGL headers and libraries.
#
#  FTGL_INCLUDE_DIRS - Where to find FTGL.h, etc.
#  FTGL_LIBRARIES    - List of libraries when using FTGL.
#  FTGL_FOUND        - True if FTGL found.
#  FTGL_INCLUDE_IS_UPPER - True if the include file to use is FTGL.h.

include( H3DCommonFindModuleFunctions )
get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )
getExternalSearchPathsH3D( module_include_search_paths module_lib_search_paths ${module_file_path} "FTGL" )

# Look for the header file.
find_path( FTGL_INCLUDE_DIR NAMES FTGL/ftgl.h 
                            PATHS ${module_include_search_paths}
                            DOC "Path in which the file FTGL/ftgl.h is located." )

# This variable needs to be cached to know what the previous value was. The reason for this
# is because otherwise it would be set to 0 the second time FINDFTGL was run. Other solutions
# to find the file directly does not work since the FIND_FILE and if( EXISTS file_name ) are not
# case sensitive.
set( FTGL_INCLUDE_IS_UPPER "NO" CACHE BOOL "Variable used to check if FTGL include is upper. Must be changed to the correct value if FTGL_INCLUDE_DIR is set manually." )

if( NOT FTGL_INCLUDE_DIR )
  find_path( FTGL_INCLUDE_DIR NAMES FTGL/FTGL.h 
                              PATHS ${module_include_search_paths}
                              DOC "Path in which the file FTGL/FTGL.h is located." )
  # This code is only run if FTGL_INCLUDE_DIR was empty but now is not.
  if( FTGL_INCLUDE_DIR )
    set( FTGL_INCLUDE_IS_UPPER "YES" CACHE BOOL "Variable used to check if FTGL include is upper. Must be changed to the correct value if FTGL_INCLUDE_DIR is set manually." FORCE )
  endif()
endif()

mark_as_advanced( FTGL_INCLUDE_DIR )
mark_as_advanced( FTGL_INCLUDE_IS_UPPER )

# Look for the library.
find_library( FTGL_LIBRARY NAMES ftgl ftgl_dynamic_213rc5 ftgl_dynamic_MTD
                           PATHS ${module_lib_search_paths}
                           DOC "Path to ftgl library." )
mark_as_advanced( FTGL_LIBRARY )

if( WIN32 AND H3D_PREFER_STATIC_LIBRARIES )
  set( ftgl_static_library_name ftgl_static_MTD )
  if( MSVC80 )
    set( ftgl_static_library_name ftgl_static_MTD_vc8 )
  elseif( MSVC90 )
    set( ftgl_static_library_name ftgl_static_MTD_vc9 )
  endif()

  include( H3DUtilityFunctions )
  handleRenamingVariablesBackwardCompatibility( NEW_VARIABLE_NAMES FTGL_STATIC_LIBRARY_RELEASE FTGL_STATIC_LIBRARY_DEBUG
                                                OLD_VARIABLE_NAMES FTGL_STATIC_LIBRARY FTGL_STATIC_DEBUG_LIBRARY
                                                DOC_STRINGS "Path to ftgl static library."
                                                            "Path to ftgl static debug library." )
  
  set( module_include_search_paths "" )
  set( module_lib_search_paths "" )
  getExternalSearchPathsH3D( module_include_search_paths module_lib_search_paths ${module_file_path} "static" )
  
  find_library( FTGL_STATIC_LIBRARY_RELEASE NAMES ${ftgl_static_library_name}
                                         PATHS ${module_lib_search_paths}
                                    DOC "Path to ftgl static library." )
  mark_as_advanced( FTGL_STATIC_LIBRARY_RELEASE )
  
  find_library( FTGL_STATIC_LIBRARY_DEBUG NAMES ${ftgl_static_library_name}_d
                                                PATHS ${module_lib_search_paths}
                                          DOC "Path to ftgl static debug library." )
  mark_as_advanced( FTGL_STATIC_LIBRARY_DEBUG )
endif()

include( FindPackageHandleStandardArgs )
include( SelectLibraryConfigurations )
set( ftgl_static_lib 0 )

# handle the QUIETLY and REQUIRED arguments and set FTGL_FOUND to TRUE
# if all listed variables are TRUE
if( WIN32 AND H3D_PREFER_STATIC_LIBRARIES )
  select_library_configurations( FTGL_STATIC )
  find_package_handle_standard_args( FTGL DEFAULT_MSG
                                     FTGL_STATIC_LIBRARY FTGL_INCLUDE_DIR )
  set( FTGL_LIBRARIES ${FTGL_STATIC_LIBRARIES} )
  set( ftgl_static_lib ${FTGL_FOUND} ) # FTGL_FOUND is set by find_package_handle_standard_args and should be up to date here.
  if( FTGL_FOUND AND MSVC )
    if( NOT FTGL_STATIC_LIBRARY_RELEASE )
      message( WARNING "FTGL static release library not found. Release build might not work properly. To get rid of this warning set FTGL_STATIC_LIBRARY_RELEASE." )
    endif()
    if( NOT FTGL_STATIC_LIBRARY_DEBUG )
      message( WARNING "FTGL static debug library not found. Debug build might not work properly. To get rid of this warning set FTGL_STATIC_LIBRARY_DEBUG." )
    endif()
  endif()
endif()

if( NOT ftgl_static_lib ) # This goes a bit against the standard, the reason is that if static libraries are desired the normal ones are only fallback.
  find_package_handle_standard_args( FTGL DEFAULT_MSG
                                     FTGL_LIBRARY FTGL_INCLUDE_DIR )
  set( FTGL_LIBRARIES ${FTGL_LIBRARY} )
endif()

set( FTGL_INCLUDE_DIRS ${FTGL_INCLUDE_DIR} )