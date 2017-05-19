# - Find bzip2
# Find the native BZIP2 headers and libraries.
# If none is found for Windows use the distributed one in External
#
#  BZIP2_INCLUDE_DIRS - Where to find bzlib.h, etc.
#  BZIP2_LIBRARIES    - List of libraries when using bzip2.
#  BZIP2_FOUND        - True if bzip2 found.

include( H3DCommonFindModuleFunctions )

get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )
getExternalSearchPathsH3D( module_include_search_paths module_lib_search_paths ${module_file_path} "Bzip2" )

# Look for the header file.
find_path( BZIP2_INCLUDE_DIR NAMES bzlib.h
           PATHS ${module_include_search_paths}
           DOC "Path in which the file Bzip2.h is located."
           NO_SYSTEM_ENVIRONMENT_PATH )

# Look for the library.
find_library( BZIP2_LIBRARY NAMES libbz2 bz2 bzip2
              PATHS ${module_lib_search_paths}
              DOC "Path to bzip2 library."
              NO_SYSTEM_ENVIRONMENT_PATH )

mark_as_advanced( BZIP2_INCLUDE_DIR BZIP2_LIBRARY )

checkIfModuleFound( BZIP2
                    REQUIRED_VARS BZIP2_INCLUDE_DIR BZIP2_LIBRARY )

set( BZIP2_LIBRARIES ${BZIP2_LIBRARY} )
set( BZIP2_INCLUDE_DIRS ${BZIP2_INCLUDE_DIR} )

if( NOT BZIP2_FOUND )
  checkCMakeInternalModule( BZip2 OUTPUT_AS_UPPER_CASE )  # Will call CMakes internal find module for this feature.
endif()