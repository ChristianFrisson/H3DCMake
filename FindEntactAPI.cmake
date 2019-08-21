# - Find EntactAPI
# Find the native EntactAPI headers and libraries.
#
#  EntactAPI_INCLUDE_DIRS - Where to find EntactAPI headers
#  EntactAPI_LIBRARIES    - List of libraries when using EntactAPI.
#  EntactAPI_FOUND        - True if EntactAPI found.

include( H3DUtilityFunctions )

handleRenamingVariablesBackwardCompatibility( NEW_VARIABLE_NAMES EntactAPI_INCLUDE_DIR EntactAPI_LIBRARY_RELEASE
                                              OLD_VARIALBE_NAMES EntactAPI_INCLUDE_DIR ENTACTAPI_LIBRARY
                                              DOC_STRINGS "Path in which the file EntactAPI.h is located. Needed to support Entact haptics device."
                                                          "Path to EntactAPI.lib library. Needed to support Entact haptics device." )

set( entact_include_search_paths "" )
set( entact_lib_search_paths "" )
if( CMAKE_SYSTEM_NAME STREQUAL "Windows" AND CMAKE_SYSTEM_VERSION VERSION_GREATER "5.9999" )
  include( H3DCommonFindModuleFunctions )
  get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )
  getExternalSearchPathsH3D( entact_include_search_paths entact_lib_search_paths ${module_file_path} )
endif()

# Look for the header file.
find_path( EntactAPI_INCLUDE_DIR NAMES EntactAPI.h
                                 PATHS ${entact_include_search_paths}
                                 DOC "Path in which the file EntactAPI.h is located. Needed to support Entact haptics device." )
mark_as_advanced( EntactAPI_INCLUDE_DIR )

set( entact_api_lib_name EntactAPI )
if( NOT WIN32 )
  set( entact_api_lib_name entact )
endif()

# Look for the library.
find_library( EntactAPI_LIBRARY_RELEASE NAMES ${entact_api_lib_name}
                                PATHS ${entact_lib_search_paths}
                                DOC "Path to EntactAPI.lib library. Needed to support Entact haptics device." )
find_library( EntactAPI_LIBRARY_DEBUG NAMES "${entact_api_lib_name}_d"
                                PATHS ${entact_lib_search_paths}
                                DOC "Path to EntactAPI_d.lib library. Needed to support Entact haptics device." )

mark_as_advanced( EntactAPI_LIBRARY_DEBUG )
mark_as_advanced( EntactAPI_LIBRARY_RELEASE )

include( SelectLibraryConfigurations )
select_library_configurations( ${entact_api_lib_name} )

include( FindPackageHandleStandardArgs )
# handle the QUIETLY and REQUIRED arguments and set EntactAPI_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args( EntactAPI DEFAULT_MSG
                                   EntactAPI_LIBRARY EntactAPI_INCLUDE_DIR )

set( EntactAPI_LIBRARIES ${EntactAPI_LIBRARY} )
set( EntactAPI_INCLUDE_DIRS ${EntactAPI_INCLUDE_DIR} )

# Backwards compatibility values set here.
set( ENTACTAPI_INCLUDE_DIR ${EntactAPI_INCLUDE_DIRS} )
set( ENTACTAPI_LIBRARIES ${EntactAPI_LIBRARIES} )
set( EntactAPI_FOUND ${ENTACTAPI_FOUND} ) # find_package_handle_standard_args for CMake 2.8 only define the upper case variant.