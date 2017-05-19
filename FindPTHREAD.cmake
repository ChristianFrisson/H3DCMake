# - Find pthread
# Find the native PTHREAD headers and libraries.
#
#  PTHREAD_INCLUDE_DIRS -  where to find pthread.h, etc.
#  PTHREAD_LIBRARIES    - List of libraries when using pthread.
#  PTHREAD_FOUND        - True if pthread found.

include( H3DCommonFindModuleFunctions )
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

include( FindPackageHandleStandardArgs )
# handle the QUIETLY and REQUIRED arguments and set PTHREAD_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args( PTHREAD DEFAULT_MSG
                                   PTHREAD_LIBRARY PTHREAD_INCLUDE_DIR )

set( PTHREAD_LIBRARIES ${PTHREAD_LIBRARY} )
set( PTHREAD_INCLUDE_DIRS ${PTHREAD_INCLUDE_DIR} )
if( PTHREAD_FOUND AND NOT WIN32 AND UNIX )
  set( PTHREAD_LIBRARIES ${PTHREAD_LIBRARIES} dl )
endif()