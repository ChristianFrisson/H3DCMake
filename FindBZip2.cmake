# - Find bzip2
# Find the native BZIP2 headers and libraries.
# If none is found for Windows use the distributed one in External
#
#  BZIP2_INCLUDE_DIRS - Where to find bzlib.h, etc.
#  BZIP2_LIBRARIES    - List of libraries when using bzip2.
#  BZIP2_FOUND        - True if bzip2 found.

include( H3DExternalSearchPath )
checkCMakeInternalModule( BZip2 ) # Will call CMakes internal find module for this feature.

if( ( DEFINED BZIP2_FOUND ) AND BZIP2_FOUND )
  return()
endif()

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

mark_as_advanced( BZIP2_INCLUDE_DIR BZIP2_LIBRARY )

include( FindPackageHandleStandardArgs )
# handle the QUIETLY and REQUIRED arguments and set BZIP2_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args( BZIP2 DEFAULT_MSG
                                   BZIP2_LIBRARY BZIP2_INCLUDE_DIR )

set( BZIP2_LIBRARIES ${BZIP2_LIBRARY} )
set( BZIP2_INCLUDE_DIRS ${BZIP2_INCLUDE_DIR} )

# Backwards compatibility values set here.
set( BZIP2_INCLUDE_DIR ${BZIP2_INCLUDE_DIRS} )