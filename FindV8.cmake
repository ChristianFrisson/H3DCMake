# - Find V8
# Find the native V8 headers and libraries.
#
#  V8_INCLUDE_DIR -  where to find V8.h, etc.
#  V8_LIBRARIES    - List of libraries when using V8.
#  V8_FOUND        - True if V8 found.

include( H3DExternalSearchPath )
get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )
getExternalSearchPathsH3D( module_include_search_paths module_lib_search_paths ${module_file_path} "pthread" )

# Look for the header file.
find_path( V8_INCLUDE_DIR NAMES v8.h
           PATHS /usr/local/include
                 ${module_include_search_paths}
           DOC "Path in which the file v8.h is located." )
mark_as_advanced(V8_INCLUDE_DIR)

# Look for the library.
# Does this work on UNIX systems? (LINUX)
find_library( V8_LIBRARY NAMES v8
              PATHS ${module_lib_search_paths}
              DOC "Path to v8 library." )
mark_as_advanced(V8_LIBRARY)

# Copy the results to the output variables.
if(V8_INCLUDE_DIR AND V8_LIBRARY)
  set(V8_FOUND 1)
  set(V8_LIBRARIES ${V8_LIBRARY})
  set(V8_INCLUDE_DIR ${V8_INCLUDE_DIR})
else(V8_INCLUDE_DIR AND V8_LIBRARY)
  set(V8_FOUND 0)
  set(V8_LIBRARIES)
  set(V8_INCLUDE_DIR)
endif(V8_INCLUDE_DIR AND V8_LIBRARY)

# Report the results.
if(NOT V8_FOUND)
  set(V8_DIR_MESSAGE
    "V8 was not found. Make sure V8_LIBRARY and V8_INCLUDE_DIR are set.")
  if(V8_FIND_REQUIRED)
    message(FATAL_ERROR "${V8_DIR_MESSAGE}")
  elseif(NOT V8_FIND_QUIETLY)
    message(STATUS "${V8_DIR_MESSAGE}")
  endif(V8_FIND_REQUIRED)
endif(NOT V8_FOUND)
