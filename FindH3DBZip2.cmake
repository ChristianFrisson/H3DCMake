# - Find bzip2
# Find the native BZIP2 headers and libraries.
# If none is found for Windows use the distributed one in External
#
#  BZIP2_INCLUDE_DIR -  where to find bzlip.h, etc.
#  BZIP2_LIBRARIES    - List of libraries when using bzip2.
#  BZIP2_FOUND        - True if bzip2 found.

if( H3DBZip2_FIND_REQUIRED )
  if( WIN32 )
    find_package(BZip2 QUIET REQUIRED)
  else()
    find_package(BZip2 REQUIRED)
  endif()
else()
  if( WIN32 )
    find_package(BZip2 QUIET)
  else()
    find_package(BZip2)
  endif()
endif()

if( NOT BZIP2_FOUND AND WIN32 )
  include( H3DExternalSearchPath )
  get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )
  getExternalSearchPathsH3D( module_include_search_paths module_lib_search_paths ${module_file_path} "Bzip2" )
  
  # Look for the header file.
  find_path( BZIP2_INCLUDE_DIR NAMES bzlib.h
             PATHS ${module_include_search_paths}
             DOC "Path in which the file Bzip2.h is located." )
  
  # Look for the library.
  find_library( BZIP2_LIBRARY NAMES libbz2 bz2 bzip2 
                PATHS ${module_lib_search_paths}
                DOC "Path to bzip2 library." )
  
  if( BZIP2_INCLUDE_DIR AND BZIP2_LIBRARY )
    set( BZIP2_FOUND 1 )
    set( BZIP2_LIBRARIES ${BZIP2_LIBRARY} )
    set( BZIP2_INCLUDE_DIR ${BZIP2_INCLUDE_DIR} )
  endif()
endif()

# Report the results.
if( NOT BZIP2_FOUND )
  set( BZIP2_DIR_MESSAGE
       "BZIP2 was not found. Make sure BZIP2_LIBRARY (or BZIP2_LIBRARY_RELEASE and BZIP2_LIBRARY_DEBUG ) and BZIP2_INCLUDE_DIR are set if compressed files support is desired." )
  if( H3DBZip2_FIND_REQUIRED )
      set( BZIP2_DIR_MESSAGE
           "BZIP2 was not found. Make sure BZIP2_LIBRARY or BZIP2_LIBRARY_RELEASE and BZIP2_LIBRARY_DEBUG ) and BZIP2_INCLUDE_DIR are set. BZIP2 is required to build." )
      message( FATAL_ERROR "${BZIP2_DIR_MESSAGE}" )
  elseif( NOT H3DBZIP2_FIND_QUIETLY )
    message( STATUS "${BZIP2_DIR_MESSAGE}" )
  endif()
endif()

mark_as_advanced( BZIP2_INCLUDE_DIR BZIP2_LIBRARY )
