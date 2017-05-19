# - Find HACD
# Find the native HACD headers and libraries.
#
#  HACD_INCLUDE_DIRS - Where to find the include files of HACD
#  HACD_LIBRARIES    - List of libraries when using HACD.
#  HACD_FOUND        - True if HACD found.

include( H3DUtilityFunctions )

handleRenamingVariablesBackwardCompatibility( NEW_VARIABLE_NAMES HACD_LIBRARY_RELEASE HACD_LIBRARY_DEBUG
                                              OLD_VARIABLE_NAMES HACD_LIB HACD_DEBUG_LIB )

include( H3DCommonFindModuleFunctions )
get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )
getExternalSearchPathsH3D( module_include_search_paths module_lib_search_paths ${module_file_path} "hacd" "static" )

if( CMAKE_CL_64 )
  set( lib "64" )
else()
  set( lib "32" )
endif()

set( HACD_INSTALL_DIR "" CACHE PATH "Path to external HACD installation" )

# Look for the header file.
find_path( HACD_INCLUDE_DIR NAMES hacdHACD.h
           PATHS /usr/local/include
                 ${HACD_INSTALL_DIR}/build/win${lib}/output/include
                 ${module_include_search_paths} )

mark_as_advanced( HACD_INCLUDE_DIR )

find_library( HACD_LIBRARY_RELEASE NAMES HACD_LIB
              PATHS ${HACD_INSTALL_DIR}/build/win${lib}/output/bin
                    ${module_lib_search_paths} )
mark_as_advanced( HACD_LIBRARY_RELEASE )

# Look for the library.
if( WIN32 )
  find_library( HACD_LIBRARY_DEBUG NAMES HACD_LIB_DEBUG
                PATHS ${HACD_INSTALL_DIR}/build/win${lib}/output/bin
                      ${module_lib_search_paths} )

   mark_as_advanced( HACD_LIBRARY_DEBUG )
endif()

include( SelectLibraryConfigurations )
select_library_configurations( HACD )

include( FindPackageHandleStandardArgs )
# handle the QUIETLY and REQUIRED arguments and set HACD_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args( HACD DEFAULT_MSG
                                   HACD_INCLUDE_DIR HACD_LIBRARY )

set( HACD_LIBRARIES ${HACD_LIBRARY} )
set( HACD_INCLUDE_DIRS ${HACD_INCLUDE_DIR} )

if( HACD_FOUND AND MSVC )
  if( NOT HACD_LIBRARY_RELEASE )
    message( WARNING "HACD release library not found. Release build might not work properly. To get rid of this warning set HACD_LIBRARY_RELEASE." )
  endif()
  if( NOT HACD_LIBRARY_DEBUG )
    message( WARNING "HACD debug library not found. Debug build might not work properly. To get rid of this warning set HACD_LIBRARY_DEBUG." )
  endif()
endif()