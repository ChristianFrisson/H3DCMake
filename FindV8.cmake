# - Find V8
# Find the native V8 headers and libraries.
#
#  V8_INCLUDE_DIRS - Where to find V8.h, etc.
#  V8_LIBRARIES    - List of libraries when using V8.
#  V8_FOUND        - True if V8 found.

include( H3DCommonFindModuleFunctions )
get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )
getExternalSearchPathsH3D( module_include_search_paths module_lib_search_paths ${module_file_path} "pthread" )

# Look for the header file.
find_path( V8_INCLUDE_DIR NAMES v8.h
           PATHS /usr/local/include
                 ${module_include_search_paths}
           DOC "Path in which the file v8.h is located." )
mark_as_advanced( V8_INCLUDE_DIR )

# Look for the library.
# Does this work on UNIX systems? (LINUX)
find_library( V8_LIBRARY NAMES v8
              PATHS ${module_lib_search_paths}
              DOC "Path to v8 library." )
mark_as_advanced( V8_LIBRARY )

include( FindPackageHandleStandardArgs )
# handle the QUIETLY and REQUIRED arguments and set V8_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args( V8 DEFAULT_MSG
                                   V8_LIBRARY V8_INCLUDE_DIR )

set( V8_LIBRARIES ${V8_LIBRARY} )
set( V8_INCLUDE_DIRS ${V8_INCLUDE_DIR} )

# Backwards compatibility values set here.
set( V8_INCLUDE_DIR ${V8_INCLUDE_DIRS} )