# - Find VirtuoseAPI
# Find the native VirtuoseAPI headers and libraries.
#
#  VirtuoseAPI_INCLUDE_DIRS -  where to find VirtuoseAPI headers
#  VirtuoseAPI_LIBRARIES    - List of libraries when using VirtuoseAPI.
#  VirtuoseAPI_FOUND        - True if VirtuoseAPI found.

include( H3DUtilityFunctions )
handleRenamingVariablesBackwardCompatibility( NEW_VARIABLE_NAMES VirtuoseAPI_INCLUDE_DIR VirtuoseAPI_LIBRARY
                                              OLD_VARIABLE_NAMES VIRTUOSE_INCLUDE_DIR VIRTUOSE_LIBRARY
                                              DOC_STRINGS "Path in which the file VirtuoseAPI.h is located. Needed to support Haption haptics device such as the Virtuose series."
                                                          "Path to virtuoseDLL.lib library. Needed to support Haption haptics device such as the Virtuose series." )

get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )

set( virtuoseapi_include_search_paths "" )
set( virtuoseapi_lib_search_paths "" )
if( NOT MSVC14 )
  include( H3DCommonFindModuleFunctions )
  getExternalSearchPathsH3D( virtuoseapi_include_search_paths virtuoseapi_lib_search_paths ${module_file_path} )
endif()

# Look for the header file.
find_path( VirtuoseAPI_INCLUDE_DIR NAMES VirtuoseAPI.h
                                PATHS ${virtuoseapi_include_search_paths}
                                DOC "Path in which the file VirtuoseAPI.h is located. Needed to support Haption haptics device such as the Virtuose series." )
mark_as_advanced( VirtuoseAPI_INCLUDE_DIR )


# Look for the library.
if( WIN32 )
  find_library( VirtuoseAPI_LIBRARY NAMES virtuoseDLL
                           PATHS ${virtuoseapi_lib_search_paths}
                           DOC "Path to virtuoseDLL.lib library. Needed to support Haption haptics device such as the Virtuose series." )
else()
  find_library( VirtuoseAPI_LIBRARY NAMES virtuose
                           PATHS ${virtuoseapi_lib_search_paths}
                           DOC "Path to virtuose library. Needed to support Haption haptics device such as the Virtuose series." )

endif()
mark_as_advanced( VirtuoseAPI_LIBRARY )

include( FindPackageHandleStandardArgs )
# handle the QUIETLY and REQUIRED arguments and set VirtuoseAPI_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args( VirtuoseAPI DEFAULT_MSG
                                   VirtuoseAPI_LIBRARY VirtuoseAPI_INCLUDE_DIR )

set( VirtuoseAPI_LIBRARIES ${VirtuoseAPI_LIBRARY} )
set( VirtuoseAPI_INCLUDE_DIRS ${VirtuoseAPI_INCLUDE_DIR} )

# Backwards compatibility values set here.
set( VIRTUOSE_INCLUDE_DIR ${VirtuoseAPI_INCLUDE_DIRS} )
set( VIRTUOSE_LIBRARIES ${VirtuoseAPI_LIBRARIES} )
set( VirtuoseAPI_FOUND ${VIRTUOSEAPI_FOUND} ) # find_package_handle_standard_args for CMake 2.8 only define the upper case variant.
set( VIRTUOSE_FOUND  ${VirtuoseAPI_FOUND} )