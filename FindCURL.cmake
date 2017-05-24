# - Find curl
# Find the native curl headers and libraries.
# If none is found for Windows use the distributed one in External
#
#  CURL_INCLUDE_DIRS - Where to find curl.h, etc.
#  CURL_LIBRARIES    - List of libraries when using curl.
#  CURL_FOUND        - True if curlfound.

include( H3DCommonFindModuleFunctions )

get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )
getExternalSearchPathsH3D( module_include_search_paths module_lib_search_paths ${module_file_path} )
# Look for the header file.
find_path( CURL_INCLUDE_DIR NAMES curl/curl.h
           PATHS ${module_include_search_paths}
           DOC "Path in which the file curl/curl.h is located." )
# Look for the library.
find_library( CURL_LIBRARY NAMES libcurl
              PATHS ${module_lib_search_paths}
              DOC "Path to libcurl library." )

if( WIN32 AND H3D_PREFER_STATIC_LIBRARIES )
  set( module_include_search_paths "" )
  set( module_lib_search_paths "" )
  getExternalSearchPathsH3D( module_include_search_paths module_lib_search_paths ${module_file_path} "static" )
  find_library( CURL_STATIC_LIBRARY NAMES libcurl
                                          PATHS ${module_lib_search_paths}
                                    DOC "Path to libcurl static library." )
  mark_as_advanced( CURL_STATIC_LIBRARY )
endif()

set( curl_staticlib 0 )
# handle the QUIETLY and REQUIRED arguments and set CURL_FOUND to TRUE
# if all listed variables are TRUE
if( WIN32 AND H3D_PREFER_STATIC_LIBRARIES )
  checkIfModuleFound( CURL
                      REQUIRED_VARS CURL_INCLUDE_DIR CURL_STATIC_LIBRARY )
  set( CURL_LIBRARIES ${CURL_STATIC_LIBRARY} )
  set( curl_staticlib ${CURL_FOUND} ) # CURL_FOUND is set by checkIfModuleFound and should be up to date here.
endif()

if( NOT curl_staticlib ) # This goes a bit against the standard, the reason is that if static libraries are desired the normal ones are only fallback.
  checkIfModuleFound( CURL
                      REQUIRED_VARS CURL_INCLUDE_DIR CURL_LIBRARY )
  set( CURL_LIBRARIES ${CURL_LIBRARY} )
endif()

set( CURL_INCLUDE_DIRS ${CURL_INCLUDE_DIR} )

if( NOT CURL_FOUND )
  checkCMakeInternalModule( CURL )  # Will call CMakes internal find module for this feature.
endif()

# Backwards compatibility values set here.
set( CURL_INCLUDE_DIR ${CURL_INCLUDE_DIRS} )