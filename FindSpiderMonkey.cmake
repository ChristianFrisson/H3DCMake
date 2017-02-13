# - Find SPIDERMONKEY
# Find the native SPIDERMONKEY headers and libraries.
#
#  SPIDERMONKEY_INCLUDE_DIR -  where to find SPIDERMONKEY.h, etc.
#  SPIDERMONKEY_LIBRARIES    - List of libraries when using SPIDERMONKEY.
#  SPIDERMONKEY_FOUND        - True if SPIDERMONKEY found.

include( H3DExternalSearchPath )
get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )
getExternalSearchPathsH3D( module_include_search_paths module_lib_search_paths ${module_file_path} "js" )

# Look for the header file.
find_path( SPIDERMONKEY_INCLUDE_DIR NAMES jsapi.h
           PATHS /usr/local/include
                 /usr/local/include/mozjs
                 /usr/local/include/js
                 /opt/local/include/js
                 /usr/include/mozjs
                 /usr/include/js
                 ${module_include_search_paths}
           DOC "Path in which the file jsapi.h is located." )
mark_as_advanced( SPIDERMONKEY_INCLUDE_DIR )

# Look for the library.
# Does this work on UNIX systems? (LINUX)
if( WIN32 )
  find_library( SPIDERMONKEY_LIBRARY NAMES js32
                PATHS ${module_lib_search_paths}
                DOC "Path to js32 library." )
else()
  find_library( SPIDERMONKEY_LIBRARY NAMES mozjs js
                                     DOC "Path to mozjs library." )
endif()
mark_as_advanced( SPIDERMONKEY_LIBRARY )

# Copy the results to the output variables.
if( SPIDERMONKEY_INCLUDE_DIR AND SPIDERMONKEY_LIBRARY )
  set( SPIDERMONKEY_FOUND 1 )
  set( SPIDERMONKEY_LIBRARIES ${SPIDERMONKEY_LIBRARY} )
  set( SPIDERMONKEY_INCLUDE_DIR ${SPIDERMONKEY_INCLUDE_DIR} )
else()
  set( SPIDERMONKEY_FOUND 0 )
  set( SPIDERMONKEY_LIBRARIES )
  set( SPIDERMONKEY_INCLUDE_DIR )
endif()

# Report the results.
if( NOT SPIDERMONKEY_FOUND )
  set( SPIDERMONKEY_DIR_MESSAGE
       "SPIDERMONKEY was not found. Make sure SPIDERMONKEY_LIBRARY and SPIDERMONKEY_INCLUDE_DIR are set." )
  if( Spidermonkey_FIND_REQUIRED )
    message( FATAL_ERROR "${SPIDERMONKEY_DIR_MESSAGE}" )
  elseif( NOT Spidermonkey_FIND_QUIETLY )
    message( STATUS "${SPIDERMONKEY_DIR_MESSAGE}" )
  endif()
endif()
