# - Find fparser
# Find the native fparser headers and libraries.
#
#  fparser_INCLUDE_DIRS -  where to find fparser headers
#  fparser_LIBRARIES    - List of libraries when using fparser.
#  fparser_FOUND        - True if fparser found.
include( H3DExternalSearchPath )
get_filename_component( module_file_path ${CMAKE_CURRENT_LIST_FILE} PATH )
getExternalSearchPathsH3D( module_include_search_paths module_lib_search_paths ${module_file_path} "fparser" )

# Look for the header file.
find_path(fparser_INCLUDE_DIR NAMES fparser.hh
                          PATHS ${module_include_search_paths}
                          DOC "Path in which the file fparser.hh is located." )
mark_as_advanced(fparser_INCLUDE_DIR)


# Look for the library.
find_library(fparser_LIBRARY NAMES fparser 
                             PATHS ${module_lib_search_paths}
                             DOC "Path to fparser.lib library." )
mark_as_advanced(fparser_LIBRARY)

find_library(fparser_DEBUG_LIBRARY NAMES fparser_d
                                   PATHS ${module_lib_search_paths}
                                   DOC "Path to fparser.lib library." )
mark_as_advanced(fparser_DEBUG_LIBRARY)


# Copy the results to the output variables.
if(fparser_INCLUDE_DIR AND fparser_LIBRARY)
  set(fparser_FOUND 1)
  if( fparser_DEBUG_LIBRARY )
    set(fparser_LIBRARIES optimized ${fparser_LIBRARY} debug ${fparser_DEBUG_LIBRARY} )
  else( fparser_DEBUG_LIBRARY )
    set(fparser_LIBRARIES ${fparser_LIBRARY})
    if( MSVC )
      message( WARNING "fparser debug library not found. Debug build might not work properly." )
    endif( MSVC )
  endif( fparser_DEBUG_LIBRARY )
  
  set(fparser_INCLUDE_DIRS ${fparser_INCLUDE_DIR})
else(fparser_INCLUDE_DIR AND fparser_LIBRARY)
  set(fparser_FOUND 0)
  set(fparser_LIBRARIES)
  set(fparser_INCLUDE_DIRS)
endif(fparser_INCLUDE_DIR  AND fparser_LIBRARY)

# Report the results.
if(NOT fparser_FOUND)
  set( fparser_DIR_MESSAGE
       "fparser was not found. Make sure to set fparser_LIBRARY" )
  set( fparser_DIR_MESSAGE
       "${fparser_DIR_MESSAGE} and fparser_INCLUDE_DIR. If you do not have fparser library you will not be able to use function parser nodes.")
  if(fparser_FIND_REQUIRED)
    message(FATAL_ERROR "${fparser_DIR_MESSAGE}")
  elseif(NOT fparser_FIND_QUIETLY)
    message(STATUS "${fparser_DIR_MESSAGE}")
  endif(fparser_FIND_REQUIRED)
endif(NOT fparser_FOUND)
