# - Find zlib
# Find the native ZLIB headers and libraries.
# If none is found for Windows use the distributed one in External
#
#  ZLIB_INCLUDE_DIR -  where to find zlib.h, etc.
#  ZLIB_LIBRARIES    - List of libraries when using zlib.
#  ZLIB_FOUND        - True if zlib found.


if( WIN32 )
  set( ZLIB_FIND_QUIETLY 1 )
endif()
if( H3DZLIB_FIND_REQUIRED )
  find_package(ZLIB REQUIRED)
else()
  find_package(ZLIB)
endif()

if( NOT ZLIB_FOUND AND WIN32 )
  include( H3DExternalSearchPath )
  get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )
  getExternalSearchPathsH3D( module_include_search_paths module_lib_search_paths ${module_file_path} "zlib" )
  
  # Look for the header file.
  find_path( ZLIB_INCLUDE_DIR NAMES zlib.h
             PATHS ${module_include_search_paths}
             DOC "Path in which the file zlib.h is located." )
  
  # Look for the library.
  find_library( ZLIB_LIBRARY NAMES zlib 
                PATHS ${module_lib_search_paths}
                DOC "Path to zlib library." )
  
  if( ZLIB_INCLUDE_DIR AND ZLIB_LIBRARY )
    set( ZLIB_FOUND 1 )
    set( ZLIB_LIBRARIES ${ZLIB_LIBRARY} )
    set( ZLIB_INCLUDE_DIR ${ZLIB_INCLUDE_DIR} )
  endif()
endif()

# Report the results.
if( NOT ZLIB_FOUND )
  set( ZLIB_DIR_MESSAGE
       "ZLIB was not found. Make sure ZLIB_LIBRARY and ZLIB_INCLUDE_DIR are set if compressed files support is desired." )
  if( H3DZLIB_FIND_REQUIRED )
      set( LIB_DIR_MESSAGE
           "ZLIB was not found. Make sure ZLIB_LIBRARY and ZLIB_INCLUDE_DIR are set. ZLIB is required to build." )
      message( FATAL_ERROR "${ZLIB_DIR_MESSAGE}" )
  elseif( NOT H3DZLIB_FIND_QUIETLY )
    message( STATUS "${LIB_DIR_MESSAGE}" )
  endif()
endif()

mark_as_advanced( ZLIB_INCLUDE_DIR ZLIB_LIBRARY )
