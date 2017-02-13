# - Find pthread
# Find the native PTHREAD headers and libraries.
#
#  PTHREAD_INCLUDE_DIR -  where to find pthread.h, etc.
#  PTHREAD_LIBRARIES    - List of libraries when using pthread.
#  PTHREAD_FOUND        - True if pthread found.

include( H3DExternalSearchPath )
get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )
getExternalSearchPathsH3D( module_include_search_paths module_lib_search_paths ${module_file_path} "pthread" )

# Look for the header file.
find_path( PTHREAD_INCLUDE_DIR NAMES pthread.h
                               PATHS ${module_include_search_paths}
                               DOC "Path in which the file pthread.h is located." )
mark_as_advanced( PTHREAD_INCLUDE_DIR )

# Look for the library.
if( WIN32 )
  find_library( PTHREAD_LIBRARY NAMES pthreadVC2 
                                PATHS ${module_lib_search_paths}
                                DOC "Path to pthreadVC2 library." )
else()
  find_library( PTHREAD_LIBRARY NAMES pthread
                DOC "Path to pthread library." )
endif()
mark_as_advanced( PTHREAD_LIBRARY )

# Copy the results to the output variables.
if( PTHREAD_INCLUDE_DIR AND PTHREAD_LIBRARY )
  set( PTHREAD_FOUND 1 )
  set( PTHREAD_LIBRARIES ${PTHREAD_LIBRARY} )
  if( NOT WIN32 AND UNIX )
    set( PTHREAD_LIBRARIES ${PTHREAD_LIBRARIES} dl )
  endif()
  set( PTHREAD_INCLUDE_DIR ${PTHREAD_INCLUDE_DIR} )
else()
  set( PTHREAD_FOUND 0 )
  set( PTHREAD_LIBRARIES )
  set( PTHREAD_INCLUDE_DIR )
endif()

# Report the results.
if( NOT PTHREAD_FOUND )
  set( PTHREAD_DIR_MESSAGE
       "PTHREAD was not found. Make sure PTHREAD_LIBRARY and PTHREAD_INCLUDE_DIR are set." )
  if( PTHREAD_FIND_REQUIRED )
    set( PTHREAD_DIR_MESSAGE
         "${PTHREAD_DIR_MESSAGE} Pthread is required to build." )
    message( FATAL_ERROR "${PTHREAD_DIR_MESSAGE}" )
  elseif( NOT PTHREAD_FIND_QUIETLY )
    set( PTHREAD_DIR_MESSAGE
         "${PTHREAD_DIR_MESSAGE} Threading support will be disabled without PTHREAD." )
    message( STATUS "${PTHREAD_DIR_MESSAGE}" )
  endif()
endif()
