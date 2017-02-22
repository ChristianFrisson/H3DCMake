# - Find zlib
# Find the native ZLIB headers and libraries.
# If none is found for Windows use the distributed one in External
#
#  ZLIB_INCLUDE_DIRS - Where to find zlib.h, etc.
#  ZLIB_LIBRARIES    - List of libraries when using zlib.
#  ZLIB_FOUND        - True if zlib found.

include( H3DExternalSearchPath )
checkCMakeInternalModule( ZLIB ) # Will call CMakes internal find module for this feature.
if( ( DEFINED ZLIB_FOUND ) AND ZLIB_FOUND )
  return()
endif()

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

mark_as_advanced( ZLIB_INCLUDE_DIR ZLIB_LIBRARY )

include( FindPackageHandleStandardArgs )
# handle the QUIETLY and REQUIRED arguments and set ZLIB_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args( ZLIB DEFAULT_MSG
                                   ZLIB_LIBRARY ZLIB_INCLUDE_DIR )

set( ZLIB_LIBRARIES ${ZLIB_LIBRARY} )
set( ZLIB_INCLUDE_DIRS ${ZLIB_INCLUDE_DIR} )

# Backwards compatibility values set here.
set( ZLIB_INCLUDE_DIR ${ZLIB_INCLUDE_DIRS} )