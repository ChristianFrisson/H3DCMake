# - Find curl
# Find the native curl headers and libraries.
# If none is found for Windows use the distributed one in External
#
#  CURL_INCLUDE_DIR -  where to find curl.h, etc.
#  CURL_LIBRARIES    - List of libraries when using curl.
#  CURL_FOUND        - True if curlfound.

if( WIN32 )
  set(CURL_FIND_QUIETLY 1)
endif( WIN32 )
if(H3DCURL_FIND_REQUIRED)
  find_package(CURL REQUIRED)
else(H3DCURL_FIND_REQUIRED)
  find_package(CURL)
endif(H3DCURL_FIND_REQUIRED)

if( WIN32 )
if(NOT CURL_FOUND OR PREFER_STATIC_LIBRARIES)
  include( H3DExternalSearchPath )
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

  if( PREFER_STATIC_LIBRARIES )
    set( module_include_search_paths "" )
    set( module_lib_search_paths "" )
    getExternalSearchPathsH3D( module_include_search_paths module_lib_search_paths ${module_file_path} "static" )
    find_library( CURL_STATIC_LIBRARY NAMES libcurl
                                            PATHS ${module_lib_search_paths}
                                      DOC "Path to libcurl static library." )
    mark_as_advanced(CURL_STATIC_LIBRARY)
  endif( PREFER_STATIC_LIBRARIES )

  if( CURL_LIBRARY OR CURL_STATIC_LIBRARY )
    set( CURL_LIBRARIES_FOUND 1 )
  endif( CURL_LIBRARY OR CURL_STATIC_LIBRARY )
  
  if(CURL_INCLUDE_DIR AND CURL_LIBRARIES_FOUND)
    set(CURL_FOUND 1)

    if( WIN32 AND PREFER_STATIC_LIBRARIES AND CURL_STATIC_LIBRARY )
      set(CURL_LIBRARIES ${CURL_STATIC_LIBRARY})
      set( CURL_STATICLIB 1 )
    else( WIN32 AND PREFER_STATIC_LIBRARIES AND CURL_STATIC_LIBRARY )
      set(CURL_LIBRARIES ${CURL_LIBRARY})
    endif( WIN32 AND PREFER_STATIC_LIBRARIES AND CURL_STATIC_LIBRARY )

    set(CURL_INCLUDE_DIR ${CURL_INCLUDE_DIR})
  endif(CURL_INCLUDE_DIR AND CURL_LIBRARIES_FOUND)
endif(NOT CURL_FOUND OR PREFER_STATIC_LIBRARIES)
endif( WIN32 )

# Report the results.
if(NOT CURL_FOUND)
  set(CURL_DIR_MESSAGE
    "Curl was not found. Make sure CURL_LIBRARY (and/or CURL_STATIC_LIBRARY) and CURL_INCLUDE_DIR are set.")
  if(H3DCURL_FIND_REQUIRED)
    set(CURL_DIR_MESSAGE
        "${CURL_DIR_MESSAGE} CURL is required to build.")
    message(FATAL_ERROR "${CURL_DIR_MESSAGE}")
  elseif(NOT H3DCURL_FIND_QUIETLY)
    message(STATUS "${CURL_DIR_MESSAGE}")
  endif(H3DCURL_FIND_REQUIRED)
endif(NOT CURL_FOUND)

mark_as_advanced(CURL_INCLUDE_DIR CURL_LIBRARY)
